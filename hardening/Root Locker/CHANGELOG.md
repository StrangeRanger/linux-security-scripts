# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.10 - 2025-08-10

### Changed

- Replace `[[ ]]` with `(( ))`.
- Remove redundant comments.

## v1.0.9 - 2025-08-09

### Changed

- Removed "Exiting..." message from output.

## v1.0.8 - 2024-12-20

### Changed

- Improved the colorization of the output text.

## v1.0.7 - 2024-08-15

### Changed

- Improved error handling.
- Modify syntax and documentation.
- Utilizes `usermod -L` to lock the root account.
- Rename script to `root-locker.bash`.

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
- No longer backs up `/etc/shadow`.

## v1.0.3 - 2020-12-01

### Changed

- Changed commenting style.

### Fixed

- Added missing variable to `echo`, resulting in the text color to remain cyan.

## v1.0.2 - N/A

### Changed

- Changed placement of `read -p "We will now disable the root account. Press [Enter] to continue."`.

## v1.0.0 - N/A

- Initial creation.
