# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v2.2.0 - 2025-11-02

### Added

- MaxStartups is configured to `10:30:60`. This limits concurrent unauthenticated connections to mitigate DoS attacks.

## v2.1.0 - 2025-08-09

### Added

- **Session backup system**: Automatic restoration during script interruptions with temporary backup preservation for manual recovery
- **Cross-platform SSH service restart**: Automatically detects and restarts either `sshd` or `ssh` service based on distribution
- **Enhanced signal handling**: Proper restoration and cleanup on script interruption (SIGHUP, SIGINT, SIGTERM)

### Changed

- **Backup strategy**: Dual backup system with permanent `.bak` file for user reference and session backup for auto-restoration
- **Exit handling**: Strategic use of `clean_exit` function only when cleanup or restoration is needed
- **User messaging**: Enhanced feedback throughout backup, restoration, and cleanup processes
- **Output colors**: "Already set" messages now use note (cyan) instead of success (green) for better semantic clarity

## v2.0.2 - 2024-12-20

### Changed

- Remove trap for `SIGQUIT`.
- Move around traps and cases.

## v2.0.1 - 2024-10-30

### Fixed

- Fixed trapping logic and how errors are handled.

## v2.0.0 - 2024-08-15

Complete rewrite of the script. Below are just some of the differences in the new version.

### Added

- Can catch common error signals.
- Output is now colored to better differentiate between different types of messages.

### Changes

- Improved the script's structure.
- Improved regex and replacement of sshd configurations.
- Improved error handling.
- The script has been renamed to `harden-sshd.bash`.

## v1.1.2 - 2024-04-13

### Changed

- Improved documentation and comments of code.

## v1.1.1 - 2022-07-13

### Changed

- Changed how the variables used to change the color of output text, are formatted, in the hopes of increasing portability.
- Exit codes beyond 1, were reverted back to 1.
- Other efficiency changes.

## v1.1.0 - 2022-07-10

### Added

- Sets `KbdInteractiveAuthentication` to `KbdInteractiveAuthentication no`.
  - This setting is introduced in Ubuntu 22.04, seeming to replace `ChallengeResponseAuthentication`.
- Asks if the end user would like to overwrite the existing backup of `sshd_config`, if it exists.

### Changed

- Modified exit codes.
- Modified the output text, depending on whether the specific configurations have already been set.
- Updated the flags and regex used by `sed` to set the configurations.

## v1.0.3 - 2020-12-01

### Changed

- Changed commenting style.

### Fixed

- Added missing variable to `echo`, resulting in the text color to remain cyan.

## v1.0.2 - N/A

### Added

- Checks if `sshd_config` exists before attempting to modify the file.

## v1.0.1 - N/A

### Added

- Now prompts the user before performing actions.

### Fixed

- Fixed script not wanting to run as root.

## v1.0.0

- Initial creation.
