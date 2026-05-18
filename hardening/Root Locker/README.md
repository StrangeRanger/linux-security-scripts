# Root Locker

Locks the root account to prevent direct root login.

> [!NOTE]
> This does not remove administrative access for users who already have valid sudo privileges. Users may still be able to gain a root shell through tools such as `sudo su` or `sudo -i`.

## Requirements

- Bash 4.0 or newer
- Root privileges
- `usermod`

## Usage

Run the script from the repository root:

```bash
sudo ./hardening/Root\ Locker/root-locker.bash
```

## Safety Notes

- Confirm that at least one non-root user has working sudo access before running this script.
- Do not run this on a system where direct root login is the only available administrative access path.

## Verify

Check the root account state with:

```bash
sudo passwd -S root
```

You can also confirm sudo access from a non-root administrative account:

```bash
sudo -v
```

## Tested On

- Ubuntu 24.04, 22.04, 20.04
- Debian 11, 10, 9

## Version History

See [CHANGELOG.md](CHANGELOG.md).
