# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0-beta] - 2026-05-17

### Added

- Added Nginx WAF hardening tool for installing and configuring ModSecurity with Nginx.
- Added automatic installation of required build dependencies for ModSecurity and Nginx dynamic module compilation.
- Added ModSecurity v3 source build and installation workflow.
- Added ModSecurity-nginx dynamic module build using the installed Nginx version and configure arguments.
- Added Nginx module loading configuration through `modules-available` and `modules-enabled`.
- Added OWASP Core Rule Set installation and ModSecurity main configuration generation.
- Added Nginx configuration validation and restart after setup.

### Fixed

- Added missing build dependencies required by Nginx SSL, XSLT, image filter, Perl, gzip, and ModSecurity modules.
- Removed redundant or unused dependency entries from the required package list.
