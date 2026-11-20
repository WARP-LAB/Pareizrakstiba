# PkgInstall

Builds a double-clickable macOS installer for `Pareizrakstiba.service` and
wraps it in a disk image. The Release build itself is delegated to
`../../build.sh` (bare bundle, no zip — the package wants the plain
`.service`).

## Usage

```sh
./make-installer.sh                    # unsigned, not notarized
./make-installer.sh --sign yes         # signed (see identities below)
./make-installer.sh --notarize yes     # signed + notarized (implies --sign)
```

`dmg/` (gitignored) receives the final `Pareizrakstiba.pkg` and the final
`Pareizrakstiba.dmg`. While running, intermediates live in `dmg/work/`,
which is deleted again at the end. The output names carry no version on
purpose, so a GitHub release
asset URL can always point at the same file whatever the version inside
(`.../releases/latest/download/Pareizrakstiba.dmg`). The version inside
the bundle, the pkg receipts and the DMG volume name all come from the
built bundle.

## Signing and notarization

Off by default. Each setting comes from the environment if set there,
otherwise from the resolved Release build settings, i.e.
`Config/Local.xcconfig` (option B plus the installer keys, see
`Config/Local.xcconfig.example`), so the identity Xcode signs with is
the one the installer uses:

| Setting | Used for |
| --- | --- |
| `CODE_SIGN_IDENTITY` | Developer ID **Application**: signs the `.service` bundle, the uninstaller and the `.dmg` |
| `INSTALLER_SIGN_IDENTITY` | Developer ID **Installer**: signs the `.pkg` |
| `NOTARY_PROFILE` | `notarytool` keychain profile name (default: `notarytool`) |

None of these are secrets. The notarization credentials live in the
keychain, stored once with:

```sh
xcrun notarytool store-credentials notarytool --apple-id <apple-id> --team-id <TEAMID>
```

Never put a password or API key in `Local.xcconfig`: build settings
end up in build logs and in every build script's environment.

With `--notarize yes` the run ends by validating the stapled tickets and
asking Gatekeeper (`spctl`) to accept the `.pkg` and `.dmg`, so a file
that would be rejected on a downloader's Mac fails the run instead.

Environment override example:

```sh
CODE_SIGN_IDENTITY="Developer ID Application: WARP (TEAMID)" \
INSTALLER_SIGN_IDENTITY="Developer ID Installer: WARP (TEAMID)" \
NOTARY_PROFILE="notarytool" \
./make-installer.sh --notarize yes
```

## Files

| File | Purpose |
| --- | --- |
| `make-installer.sh` | The whole pipeline: build → payload → pkg → dmg, with sign/notarize toggles. The built `.service` is consumed into the payload and removed from `build/`, so no bare bundle is left. After `pkgbuild` it strips the `auth="root"` attribute that `pkgbuild` hardcodes into the PackageInfo (expand → `sed` → flatten), so an admin password is only asked when the destination needs root |
| `validate-installer.sh` | Release check of a DMG, by default `dmg/Pareizrakstiba.dmg`, or a path such as a DMG downloaded from a GitHub release. Mounts it and checks the DMG, the `.pkg` inside it, the `.service` in the package payload and the uninstaller: Developer ID signatures, secure timestamps, hardened runtime, stapled tickets, Gatekeeper acceptance as notarized, one team throughout. One PASS/FAIL line per check, non-zero exit if any fails |
| `component.plist` | Component options; `BundleIsRelocatable` is what enables the "all users / this user" destination choice in Installer.app (not the default on macOS 27+) |
| `dist.xml` | Distribution definition (`@VERSION@` is filled from the built bundle at build time) |
| `scripts/preinstall` | Preflight: stop a running spell server, remove previous installs from `/Library/Services` (only when running as root) **and** `~/Library/Services` (always), guarded `pbs -flush` |
| `scripts/postinstall` | Postflight: remove stray zips from `/Library/Services` (only when running as root) and `~/Library/Services` (always), guarded `pbs -flush` |
| `Uninstall.applescript` | Source of the double-clickable `Uninstall Pareizrakstiba.app` shipped in the DMG. Four steps: explains what will happen, checks both install domains (no privileges needed), presents the findings — admin password only announced and asked when `/Library/Services` is involved — then stops the server, removes the install, forgets the pkg receipt, refreshes the services cache. Keeps learned words. Signed/notarized together with the rest |
| `resources/Welcome.rtf` | Welcome text, English — the fallback for any language without its own `lproj` |
| `resources/lv.lproj/Welcome.rtf` | Welcome text, Latvian — shown automatically when the system (or Installer's per-app) language is Latvian |

## Testing without double-clicking

```sh
sudo installer -pkg dmg/Pareizrakstiba.pkg -target LocalSystem
installer -pkg dmg/Pareizrakstiba.pkg -target CurrentUserHomeDirectory
pkgutil --pkg-info lv.warp.Pareizrakstiba.service
```

## Notes

- The DMG carries two items: `Pareizrakstiba.pkg` (double-click to install)
  and `Uninstall Pareizrakstiba.app` (double-click to remove — works for
  both install domains, forgets the receipt, keeps learned words).
- With `--notarize yes` the uninstaller is covered by the DMG's
  notarization (it is signed alongside the service bundle). It is not
  stapled individually; users launch it from the stapled DMG.
- The "all users / only me" choice is the Destination Select step: with
  `<domains enable_currentUserHome="true" enable_localSystem="true"/>` the
  pane offers the disk (payload lands in `/Library/Services`) and the
  user's home (payload lands in `~/Library/Services`). Relocation
  (`BundleIsRelocatable`) additionally lets the installer find and update
  an existing install in either domain.
- Installer.app picks the Welcome text by language: Latvian from
  `lv.lproj/`, English (root `Welcome.rtf`) otherwise. There is no
  in-installer language switcher — Installer.app follows the system
  language, or a per-app override in System Settings → General →
  Language & Region → Applications.
- Per-user installs need the destination choice Installer.app shows for
  relocatable bundles; if a macOS release behaves differently, the CLI
  `installer -target CurrentUserHomeDirectory` line above is the fallback.
- The packages carry no `auth="root"` attribute: `pkgbuild` hardcodes it
  into the component's PackageInfo, so `make-installer.sh` removes it
  after the build, and `dist.xml` never sets it. Installer.app therefore
  asks for an administrator password only when the chosen destination
  needs one (the disk → `/Library/Services`); a "this user only" install
  runs unprivileged, including its scripts.
- The `.service` is signed with hardened runtime (`--options runtime`) and
  a secure timestamp (`--timestamp`) so notarization accepts it.
