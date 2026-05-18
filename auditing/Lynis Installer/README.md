# Lynis Installer

Downloads [Lynis](https://github.com/CISOfy/lynis), a security auditing tool for Unix-like systems.

> [!NOTE]
> This script only downloads Lynis. It does not audit, harden, or modify system security settings by itself.

## Requirements

- Bash 4.0 or newer
- Git
- Internet access
- No root privileges required

## Usage

From the repository root:

```bash
./auditing/Lynis\ Installer/lynis-installer.bash
```

OR from the script directory:

```bash
./lynis-installer.bash
```

## After Installation

To run a Lynis system audit:

```bash
cd ~/lynis
clear
sudo ./lynis audit system
```

Before applying hardening changes, review the Lynis output carefully. Treat its findings as recommendations, not as a replacement for understanding your system’s security posture.

## Tested On

- Ubuntu 24.04, 22.04, 20.04
- Debian 11, 10, 9

## Version History

See [CHANGELOG.md](CHANGELOG.md).
