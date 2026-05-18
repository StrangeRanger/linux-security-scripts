# UFW Cloudflare

Configures UFW to allow inbound HTTP and HTTPS traffic only from Cloudflare IP ranges.

Use this script for hosts where public web traffic should reach the origin server through Cloudflare rather than directly from the internet.

## Requirements

- Bash 4.0 or newer
- Root privileges
- UFW
- `curl`
- `tar`
- Internet access

## Usage

From the repository root:

```bash
sudo ./hardening/UFW\ Cloudflare/ufw-cloudflare.bash
```

OR from the script directory:

```bash
sudo ./ufw-cloudflare.bash
```

## Execution Summary

- Reads existing UFW rules marked with the `Cloudflare IP` comment.
- Downloads current Cloudflare IPv4 and IPv6 ranges from Cloudflare.
- Creates a temporary backup archive of `/etc/ufw`.
- Temporarily allows ports `80` and `443` from any IP to avoid traffic interruption while rules are replaced.
- Removes existing Cloudflare-marked rules.
- Adds new UFW allow rules for Cloudflare IP ranges on TCP ports `80` and `443`.
- Removes the temporary allow rule.

## Backups and Recovery

The script creates a temporary backup archive similar to:

```text
/tmp/.../ufw-backup-YYYY-MM-DD.tar.gz
```

If the script is interrupted during rule replacement, it attempts to:

- Disable UFW temporarily.
- Restore the previous UFW configuration from the backup archive.
- Re-enable UFW.
- Print the current UFW status.

The temporary backup is removed during normal cleanup.

## Safety Notes

- Direct origin access may remain possible through other open ports or non-UFW firewall layers.

## Verify

Review UFW status after the script finishes:

```bash
sudo ufw status verbose
```

You can also inspect numbered rules:

```bash
sudo ufw status numbered
```

## Tested On

- Ubuntu 24.04, 22.04, 20.04
- Debian 11, 10, 9

## Version History

See [CHANGELOG.md](CHANGELOG.md).
