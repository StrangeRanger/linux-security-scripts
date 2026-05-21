# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.4 - 2026-05-21

### Fixed

- Replaced the use of `exit 1` with `clean_exit 1` to ensure temp files are removed on exits.

## v1.0.3 - 2026-05-21

### Added

- Add a diagnostic `ERR` trap that reports the failing command and line number before exiting.

### Changed

- Enable strict Bash error handling with `set -euo pipefail`.
- Move the UFW active-status check after the user confirmation prompt.
- Create the UFW backup archive as a gzip-compressed tar archive.
- Reuse the Cloudflare UFW comment constant when reading existing Cloudflare-marked rules.

### Fixed

- Replace the `yes | ufw delete` pipeline with a single `y` response to avoid `SIGPIPE` failures under `pipefail`.
- Use the `-z` flag when restoring archived backup files to handle gzip-compressed tar archives correctly.

## v1.0.2 - 2026-05-20

### Changed

- Track active rule changes with boolean.

### Fixed

- Fix duplicate "Waiting X second for changes to take effect" when no existing Cloudflare rules are present.

## v1.0.1 - 2025-08-10

### Fixed

- Remove temp files on exit to avoid leftovers.

## v1.0.0 - 2025-08-09

- Full production-ready release
