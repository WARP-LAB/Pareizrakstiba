#!/usr/bin/env bash
# Generates compile_commands.json - the clangd compilation database - for this
# Xcode project, using bear.
#
# Why this dance instead of simply `bear -- xcodebuild build`:
#   1. xcodebuild sanitizes DYLD_INSERT_LIBRARIES out of the environment of the
#      tools it spawns, so bear's interposer never reaches the clang processes
#      and the database comes out empty.
#   2. The full clang command lines are only echoed for scheme-based builds
#      (not -target based, which build.sh uses).
#   3. Apple's hardened-runtime /bin/bash also strips the injection variable
#      for its children, so replaying via a shell captures nothing; each clang
#      is exec'd directly under bear.
#   4. bear 4.x on macOS mis-records four Xcode-internal flags (drops their
#      values), which corrupts the database; they are stripped before replay.
#      They are build plumbing and irrelevant to clangd:
#        -ivfsstatcache -index-store-path --serialize-diagnostics
#        -index-unit-output-path
#   5. The commands use Clang modules (-fmodules ...). clangd cannot reliably
#      build implicit modules (e.g. after DerivedData is cleaned, every file
#      fails with "could not build module 'Foundation'"), so module flags are
#      stripped as well and headers are parsed textually. Because they sit
#      inside the @...-common-args.resp files, those are expanded too - which
#      also makes the database independent of the response files.
#
# The database references headermap/response files inside the scheme's
# DerivedData, so regenerate it after cleaning DerivedData or after adding,
# removing, or changing project files or settings.
#
# Usage: ./clangd_generate.sh [release|debug]   (default: release)
#
# The configuration selects which build settings end up in the database
# (Release has no DEBUG=1 and optimizes); Debug usually matches the
# editing experience better.

set -euo pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PROJECT="${SCRIPT_DIR}/Pareizrakstiba.xcodeproj"
SCHEME=Pareizrakstiba
CONFIGURATION=Release
DATABASE="${SCRIPT_DIR}/compile_commands.json"

if [ $# -gt 1 ]; then
	echo "usage: $( basename "${BASH_SOURCE[0]}" ) [release|debug]" >&2
	exit 1
elif [ $# -eq 1 ]; then
	CONFIGURATION=$1
fi
case "${CONFIGURATION}" in
	debug | Debug) CONFIGURATION=Debug ;;
	release | Release) CONFIGURATION=Release ;;
	*)
		echo "error: unknown configuration '${CONFIGURATION}' (expected release or debug)" >&2
		exit 1
		;;
esac

for TOOL in bear xcodebuild python3; do
	command -v "${TOOL}" >/dev/null 2>&1 || {
		echo "error: ${TOOL} not found in PATH" >&2
		exit 1
	}
done

LOG=$( mktemp )
trap 'rm -f "${LOG}"' EXIT

# Scheme's DerivedData directory, from the build settings.
OBJROOT=$( xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -configuration "${CONFIGURATION}" -showBuildSettings 2>/dev/null \
	| sed -n 's/^ *OBJROOT = //p' | head -n 1 )
if [ -z "${OBJROOT}" ]; then
	echo "error: could not read build settings for scheme ${SCHEME}" >&2
	exit 1
fi
DERIVED_DATA=$( dirname "$( dirname "${OBJROOT}" )" )

# A clean state guarantees every translation unit is compiled (and therefore
# echoed) and that the database references fresh headermaps.
echo "Cleaning ${DERIVED_DATA}"
rm -rf "${DERIVED_DATA}"

echo "Building (${CONFIGURATION}) to capture compile commands"
if ! xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -configuration "${CONFIGURATION}" build > "${LOG}" 2>&1; then
	echo "error: xcodebuild failed; last lines:" >&2
	tail -n 40 "${LOG}" >&2
	exit 1
fi

# Extract unique clang -c commands, strip the four mis-recorded Xcode flags,
# and replay each command under bear (clang exec'd directly, no shell in
# between, so the interposer survives).
python3 - "${LOG}" "${DATABASE}" <<'PY'
import json, shlex, subprocess, sys, re

log_path, database_path = sys.argv[1], sys.argv[2]
STRIP_WITH_VALUE = {'-ivfsstatcache', '-index-store-path',
                    '--serialize-diagnostics', '-index-unit-output-path'}
STRIP_EXACT = {'-fmodules', '-fno-cxx-modules', '-gmodules',
               '-fmodules-validate-once-per-build-session'}

def strip(argv):
    out, skip = [], False
    for tok in argv:
        if skip:
            skip = False
            continue
        if tok in STRIP_WITH_VALUE:
            skip = True   # drop the flag and its value
            continue
        if tok in STRIP_EXACT or tok.startswith(('-fmodules-cache-path=',
                                                 '-fbuild-session-file=')):
            continue
        out.append(tok)
    return out

cmds, seen = [], set()
for line in open(log_path).read().splitlines():
    s = line.strip()
    if not (s.startswith('/Applications/Xcode.app')
            and ' -c ' in s and ' -o ' in s):
        continue
    m = re.search(r'-c (\S+\.(?:mm|cxx|cpp|m|c))(?:\s|$)', s)
    if not m or m.group(1) in seen:
        continue
    seen.add(m.group(1))
    argv, skip = [], False
    toks = shlex.split(s)
    toks = strip(toks)
    # Expand @response files, then strip module flags that live inside them.
    expanded = []
    for tok in toks:
        if tok.startswith('@'):
            expanded.extend(shlex.split(open(tok[1:]).read()))
        else:
            expanded.append(tok)
    argv = strip(expanded)
    if argv[0].endswith('/clang') and '-c' in argv:
        cmds.append(argv)

if not cmds:
    sys.exit('error: no compile commands found in the build log')

subprocess.run(['rm', '-f', database_path], check=True)
for argv in cmds:
    subprocess.run(['bear', '--append', '--output', database_path, '--'] + argv,
                   check=True, capture_output=True)

db = json.load(open(database_path))
files = [e['file'] for e in db]
print(f'wrote {database_path}: {len(db)} entries')
for f in sorted(files):
    print('   ', f.split('/Pareizrakstiba/')[-1])
if len(db) != len(cmds):
    sys.exit('error: recorded fewer commands than replayed')
PY

echo
echo "Done. Regenerate whenever DerivedData is cleaned or project files change."
