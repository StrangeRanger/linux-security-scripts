# Linux Security Scripts

[![Project Tracker](https://img.shields.io/badge/repo%20status-Project%20Tracker-lightgrey)](https://hthompson.dev/project-tracker#project-293920085)
[![Style Guide](https://img.shields.io/badge/code%20style-Style%20Guide-blueviolet)](https://bsg.hthompson.dev/)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/598c2083cd6f432a910a315fd10aaa66)](https://www.codacy.com/gh/StrangeRanger/linux-security-scripts/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=StrangeRanger/linux-security-scripts&amp;utm_campaign=Badge_Grade)

This repository is a collection of independent scripts designed to audit and harden Linux-based distributions.

Each script is intended to be used on its own. There is no required install order, shared runtime, or single hardening profile for the whole repository. Review the README for the specific script you plan to run before applying it to a system.

<details>
<summary><strong>Table of Contents</strong></summary>

- [Linux Security Scripts](#linux-security-scripts)
  - [Tools and Scripts](#tools-and-scripts)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Download and Setup](#download-and-setup)
  - [Usage](#usage)
    - [Optional Audit Workflow](#optional-audit-workflow)
    - [Individual Script Usage](#individual-script-usage)
  - [After Running a Script](#after-running-a-script)
  - [Compatibility](#compatibility)
  - [Other Resources](#other-resources)
    - [Security Auditing Tools](#security-auditing-tools)
    - [Additional Hardening Resources](#additional-hardening-resources)
    - [System Monitoring](#system-monitoring)
  - [Support and Issues](#support-and-issues)
  - [License](#license)

</details>

## Tools and Scripts

Below is a list of scripts included in this repository. Each script has its own README with requirements, usage, compatibility notes, safety warnings, and a changelog link.

| Script | Purpose | Category | Details |
|--------|---------|----------|---------|
| **Lynis Installer** | Download Lynis, a security auditing tool for Unix-like systems. | Auditing | [README](auditing/Lynis%20Installer/README.md) / [Script](auditing/Lynis%20Installer/lynis-installer.bash) |
| **Root Locker** | Lock the root account to prevent direct root logins. | Hardening | [README](hardening/Root%20Locker/README.md) / [Script](hardening/Root%20Locker/root-locker.bash) |
| **SSHD Hardening** | Harden OpenSSH server configuration based on Lynis recommendations. | Hardening | [README](hardening/SSHD%20Hardening/README.md) / [Script](hardening/SSHD%20Hardening/harden-sshd.bash) |
| **UFW Cloudflare** | Configure UFW to allow HTTP/HTTPS traffic only from Cloudflare IP ranges. | Hardening | [README](hardening/UFW%20Cloudflare/README.md) / [Script](hardening/UFW%20Cloudflare/ufw-cloudflare.bash) |
| **Nginx WAF** | Install and configure ModSecurity with the OWASP Core Rule Set for Nginx. | Hardening | [README](hardening/Nginx%20WAF/README.md) / [Script](hardening/Nginx%20WAF/nginx-waf.bash) |

## Getting Started

### Prerequisites

The following requirements apply broadly to the repository:

- **Bash**: Version 4.0 or higher
- **Operating System**: Linux-based distribution

> [!NOTE]
> Individual scripts may require root privileges, network access, packages, or services such as OpenSSH, UFW, or Nginx. Check the script's README before running it.

### Download and Setup

All you need to do is download this repository to your local machine:

```bash
git clone https://github.com/StrangeRanger/linux-security-scripts
cd linux-security-scripts
```

## Usage

### Optional Audit Workflow

An audit-first workflow can help you decide which hardening changes are appropriate for a system:

1. **Install Lynis**: Run the Lynis installer to download the auditing tool.
   ```bash
   ./auditing/Lynis\ Installer/lynis-installer.bash
   ```

2. **Run a security audit**: Use Lynis to identify security issues.
   ```bash
   cd ~/lynis
   clear
   sudo ./lynis audit system
   ```

3. **Apply hardening selectively**: Based on the audit results, run only the hardening scripts that match your needs.

This workflow is optional. The hardening scripts do not depend on the Lynis installer.

> [!CAUTION]
> **Production Environment Warning**: Always test scripts in a non-production environment first. Some scripts modify critical system configurations and may affect system accessibility.

### Individual Script Usage

Run only the script you need. Most hardening scripts require root privileges:

```bash
sudo ./path/to/script.bash
```

Scripts can also be run through Bash directly:

```bash
bash ./path/to/script.bash
```

See each script's README for exact usage, requirements, warnings, and verification steps.

## After Running a Script

After running a script:

1. Review the script output for warnings or manual follow-up steps.
2. Verify the specific service, account, firewall, or configuration that was changed.
3. Keep any backups created by the script until you are confident the system is working correctly.
4. Re-run relevant audits or service checks after applying changes.

> [!WARNING]
> The SSHD hardening script modifies SSH configurations. Ensure you have alternative access to your system before applying changes in production environments.

## Compatibility

The scripts target Linux systems with Bash 4.0 or newer. Compatibility varies by script because each one touches different tools, services, and configuration files.

Refer to each script's README for tested distributions and script-specific compatibility notes.

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

Licensing may vary by script; see individual file headers.
