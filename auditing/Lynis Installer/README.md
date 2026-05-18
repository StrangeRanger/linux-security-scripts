# Lynis Installer

Downloads [Lynis](https://github.com/CISOfy/lynis), a security auditing tool for Unix-like systems.

This script only downloads Lynis. It does not audit, harden, or modify system security settings by itself.

## Requirements

- Bash 4.0 or newer
- Git
- Internet access
- Root privileges are not required

## Usage

Run the installer from the repository root:

```bash
./auditing/Lynis\ Installer/lynis-installer.bash
```

The script prompts before downloading Lynis.

## What It Does

- Checks whether `~/lynis` already exists.
- Changes to the current user's home directory.
- Clones the upstream Lynis repository from GitHub.
- Prints the command needed to run a system audit.

By default, Lynis is downloaded to:

```text
~/lynis
```

## After Installation

To run a Lynis system audit:

```bash
cd ~/lynis
sudo ./lynis audit system
```

Review the Lynis output before applying any hardening changes. Lynis findings are recommendations, not a replacement for understanding the system's role and access requirements.

## Tested On

- Ubuntu 24.04, 22.04, 20.04
- Debian 11, 10, 9

## Version History

See [CHANGELOG.md](CHANGELOG.md).
