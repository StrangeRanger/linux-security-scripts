# Linux Security Scripts

[![Project Tracker](https://img.shields.io/badge/repo%20status-Project%20Tracker-lightgrey)](https://wiki.hthompson.dev/en/project-tracker)
[![Style Guide](https://img.shields.io/badge/code%20style-Style%20Guide-blueviolet)](https://github.com/StrangeRanger/bash-style-guide)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/598c2083cd6f432a910a315fd10aaa66)](https://www.codacy.com/gh/StrangeRanger/linux-security-scripts/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=StrangeRanger/linux-security-scripts&amp;utm_campaign=Badge_Grade)

This repository is a collection of scripts designed to secure/harden Linux based Distributions.

<!-- TODO: Add a list of all avaliable scripts and what they do. -->

## Getting Started

### Downloading

All you need to do is download this repository to your local machine:

`git clone https://github.com/StrangeRanger/linux-security-scripts`

## Usage

> [!NOTE]
> Some of the scripts in this repository require root privileges to run. You can run the scripts with the `sudo` command to give them the necessary permissions.

You can run the scripts in this repository by using the following command:

`./[script name]` OR `bash [script name]`

## Tested On

All of the scripts should work on most, if not all Linux Distributions. With that said, below is a list of Linux Distributions that the scripts have been officially tested and are confirmed to work on.

| Distributions | Distro Versions        |
| ------------- | ---------------------- |
| Ubuntu        | 24.04, 22.04, 20.04    |
| Debian        | 11, 10, 9              |

## Other Resources

While this repository has scripts that can help secure Linux, it's not nearly enough to secure the system as much as it needs to be. Below is a list of other resources that you can/should use to help make your system as secure as possible.

- [SSH Audit](https://github.com/jtesta/ssh-audit) - SSH server & client auditing (banner, key exchange, encryption, mac, compression, compatibility, security, etc).
