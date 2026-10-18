# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0 - Unreleased

Initial version of the Nginx Cloudflare Real IP hardening script.

### Added

- Added Cloudflare IPv4 and IPv6 range retrieval with checks for failed downloads and empty responses.
- Added trusted proxy configuration generation in `/etc/nginx/conf.d/cloudflare-realip.conf`.
- Added `CF-Connecting-IP` header configuration with recursive real IP processing disabled.
- Added confirmation prompts before setup and before overwriting an existing configuration file.
- Added Nginx configuration validation and verification that the generated file is included.
- Added Nginx service restart after successful configuration checks.
- Added usage, requirements, and verification documentation.
