#!/usr/bin/env bash
# clang-format.sh — check or apply clang-format on the Pareizrakstiba source files.
#
# Usage:
#   ./clang-format.sh            # check (default): dry run, reports violations, fails on any
#   ./clang-format.sh check      # same as above
#   ./clang-format.sh fix        # apply clang-format in place
#   ./clang-format.sh --help     # show usage

set -euo pipefail

MODE="${1:-check}"

list_files() {
  git ls-files -z -- \
    'Pareizrakstiba/*.h' \
    'Pareizrakstiba/*.mm' \
    'Pareizrakstiba/*.m'
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [check|fix]

  check   Dry run against all tracked source files (default).
          Exits non-zero if any file violates .clang-format.
  fix     Run clang-format -i, rewriting files in place.
EOF
}

case "$MODE" in
  check|--check|-c)
    if [ -z "$(list_files | tr -d '\0')" ]; then
      echo "clang-format.sh: no source files found" >&2
      exit 0
    fi
    list_files | xargs -0 clang-format --dry-run -Werror
    ;;
  fix|--fix|-i)
    if [ -z "$(list_files | tr -d '\0')" ]; then
      echo "clang-format.sh: no source files found" >&2
      exit 0
    fi
    list_files | xargs -0 clang-format -i
    echo "clang-format.sh: formatted files in place"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "clang-format.sh: unknown mode '$MODE' (expected 'check' or 'fix')" >&2
    usage >&2
    exit 2
    ;;
esac
