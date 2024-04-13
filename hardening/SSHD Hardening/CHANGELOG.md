# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.1.3 - 2024-04-13

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
