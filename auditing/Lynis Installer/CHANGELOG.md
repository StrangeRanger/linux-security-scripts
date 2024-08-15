# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.7 - 2024-08-15

### Changed

- No longer requires root permission to run the script.
- Won't download lynis if is already present on the system.
- Improved syntax of the script.

## v1.0.6 - 2024-04-13

### Changed

- Improved documentation of code.

## v1.0.5 - 2022-07-13

### Changed

- Changed how the variables used to change the color of output text, are formatted, in the hopes of increasing portability.
- Exit codes beyond 1, were reverted back to 1.

## v1.0.4 - 2022-07-10

### Changed

- Modified exit codes.

## v1.0.3 - 2020-12-01

### Changed

- Changed some of the output text.

### Fixed

- Added missing variable to `echo`, resulting in the text color to remain cyan.

## v1.0.2 - N/A

### Added

- Added error catching when attempting to download lynis

### Fixed

- Fixed mistyped environmental variable from 'USER_SUDO' to 'SUDO_USER'

## v1.0.1 - N/A

### Added

- Now prompts the user before performing actions

### Fixed

- Fixed script not wanting to run as root

## v1.0.0 - N/A

- Initial creation
