# SSHD Hardening

Hardens the OpenSSH server configuration using settings aligned with [Lynis](https://github.com/CISOfy/lynis) recommendations.

> [!CAUTION]
> This script modifies the system SSH daemon configuration. Treat it as a high-risk change on remote systems because an invalid or overly restrictive SSH configuration can lock you out.

## Requirements

- Bash 4.0 or newer
- Root privileges
- OpenSSH server
- `systemctl`
- An existing `/etc/ssh/sshd_config`

## Usage

From the repository root:

```bash
sudo ./hardening/SSHD\ Hardening/harden-sshd.bash
```

OR from the script directory:

```bash
sudo ./harden-sshd.bash
```

## Changes Made

The script updates supported settings in `/etc/ssh/sshd_config` when those settings are already present in the file:

- `LogLevel VERBOSE`
- `LoginGraceTime 30`
- `PermitRootLogin no`
- `MaxAuthTries 3`
- `MaxSessions 2`
- `PubkeyAuthentication yes`
- `PermitEmptyPasswords no`
- `ChallengeResponseAuthentication no`
- `KbdInteractiveAuthentication no`
- `UsePAM yes`
- `AllowAgentForwarding no`
- `AllowTcpForwarding no`
- `X11Forwarding no`
- `PrintMotd no`
- `TCPKeepAlive no`
- `Compression no`
- `ClientAliveInterval 300`
- `ClientAliveCountMax 2`
- `MaxStartups 10:30:60`

Settings that are not present in `sshd_config` are reported but not appended automatically.

## Backups and Recovery

The script creates two backup types:

- Permanent backup: `/etc/ssh/sshd_config.bak`
- Session backup: temporary backup used for automatic restoration if the script is interrupted during configuration changes

## Safety Notes

- Keep your current SSH session open while testing a new login.
- Review whether agent forwarding, TCP forwarding, X11 forwarding, and session limits are compatible with your use case.

## Verify

Check the active SSH service status:

```bash
sudo systemctl status sshd
```

Some distributions use `ssh` instead of `sshd` as the service name:

```bash
sudo systemctl status ssh
```

Before logging out, open a new terminal and confirm that SSH login still works.

## Tested On

- Ubuntu 24.04, 22.04, 20.04
- Debian 11, 10, 9

## Version History

See [CHANGELOG.md](CHANGELOG.md).
