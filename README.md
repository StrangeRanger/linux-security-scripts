# Linux Security Scripts

[![Project Tracker](https://img.shields.io/badge/repo%20status-Project%20Tracker-lightgrey)](https://wiki.hthompson.dev/en/project-tracker)
[![Style Guide](https://img.shields.io/badge/code%20style-Style%20Guide-blueviolet)](https://github.com/StrangeRanger/bash-style-guide)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/598c2083cd6f432a910a315fd10aaa66)](https://www.codacy.com/gh/StrangeRanger/linux-security-scripts/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=StrangeRanger/linux-security-scripts&amp;utm_campaign=Badge_Grade)

This repository is a collection of scripts designed to secure/harden Linux-based distributions.

<details>
<summary><strong>Table of Contents</strong></summary>

- [Linux Security Scripts](#linux-security-scripts)
  - [Tools and Scripts](#tools-and-scripts)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Download and Setup](#download-and-setup)
  - [Usage](#usage)
    - [Quick Start](#quick-start)
    - [Individual Script Usage](#individual-script-usage)
  - [Post-Installation](#post-installation)
  - [Tested On](#tested-on)
  - [Other Resources](#other-resources)
    - [Security Auditing Tools](#security-auditing-tools)
    - [Additional Hardening Resources](#additional-hardening-resources)
    - [System Monitoring](#system-monitoring)
  - [Support and Issues](#support-and-issues)
  - [License](#license)

</details>

## Tools and Scripts

Below is a list of tools included in this repository.

| Tool Name | Description | Category | Requirements | Notes |
|-----------|-------------|----------|--------------|-------|
| **[Lynis Installer](auditing/Lynis%20Installer/lynis-installer.bash)** | Download (clone) Lynis, a security auditing tool for Unix-like systems. | Auditing | Git, Internet connection | No root required |
| **[Root Locker](hardening/Root%20Locker/root-locker.bash)** | Locks the root account to prevent direct logins. | Hardening | Root privileges | Preserves sudo access |
| **[SSHD Hardening](hardening/SSHD%20Hardening/harden-sshd.bash)** | Harden OpenSSH server (sshd) per Lynis recommendations. | Hardening | Root privileges | Creates backups |
| **[UFW Cloudflare](hardening/UFW%20Cloudflare/ufw-cloudflare.bash)** | Configure UFW to only allow HTTP/HTTPS from Cloudflare IP ranges. | Hardening | Root privileges, UFW, Internet connection | Creates backups |

> [!NOTE]
> All scripts include version information in their headers. Check individual CHANGELOG.md files in each tool's directory for version history and updates.

## Getting Started

### Prerequisites

The following requirements extend to every tool in this repository:

- **Bash**: Version 4.0 or higher
- **Operating System**: Linux-based distribution

> [!NOTE]
> Individual scripts may have additional requirements listed in the table above.

### Download and Setup

All you need to do is download this repository to your local machine:

```bash
git clone https://github.com/StrangeRanger/linux-security-scripts
cd linux-security-scripts
```

## Usage

### Quick Start

For users who want to get started immediately:

1. **Audit your system first**: Run the Lynis installer to download the auditing tool.
   ```bash
   ./auditing/Lynis\ Installer/lynis-installer.bash
   ```

2. **Run a security audit**: Use Lynis to identify security issues.
   ```bash
   cd ~/lynis && sudo ./lynis audit system
   ```

3. **Apply hardening**: Based on the audit results, run the appropriate hardening scripts with root privileges.

> [!CAUTION]
> **Production Environment Warning**: Always test scripts in a non-production environment first. Some scripts modify critical system configurations and may affect system accessibility.

### Individual Script Usage

You can run any script individually using one of the following methods:

```bash
./[script-name]
```

**or**

```bash
bash [script-name]
```

## Post-Installation

After running the hardening scripts:

1. **Verify SSH access**: Before logging out, test SSH connectivity in a new terminal session.
2. **Review firewall rules**: Check UFW status with `sudo ufw status verbose` if you used the UFW Cloudflare script.
3. **Run Lynis again**: Re-audit your system to see security improvements.
4. **Backup configurations**: Keep copies of any modified configuration files.

> [!WARNING]
> The SSHD hardening script modifies SSH configuration. Ensure you have alternative access to your system before applying changes in production environments.

## Tested On

All of the scripts should work on most, if not all, Linux distributions with Bash v4.0+ installed. With that said, below is a list of Linux distributions that the scripts have been officially tested and are confirmed to work on.

| Distributions | Distro Versions        |
| ------------- | ---------------------- |
| Ubuntu        | 24.04, 22.04, 20.04    |
| Debian        | 11, 10, 9              |

## Other Resources

Below is a list of additional resources that you can/should use to help make your system as secure as possible.

### Security Auditing Tools

- [SSH Audit](https://github.com/jtesta/ssh-audit) - SSH server & client auditing (banner, key exchange, encryption, mac, compression, compatibility, security, etc)

### Additional Hardening Resources

- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks) - Industry-standard security configuration guidelines
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework) - Comprehensive cybersecurity guidance
- [OpenSCAP](https://www.open-scap.org/) - Security compliance and vulnerability management

### System Monitoring

- [AIDE](https://aide.github.io/) - Advanced Intrusion Detection Environment
- [Fail2Ban](https://github.com/fail2ban/fail2ban) - Intrusion prevention software
- [rkhunter](http://rkhunter.sourceforge.net/) - Rootkit detection tool

## Support and Issues

Please use [GitHub Issues](https://github.com/StrangeRanger/linux-security-scripts/issues) for bug reports and feature requests.

## License

Licensing may vary by tool; see individual file headers.
