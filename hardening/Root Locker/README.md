# Root Locker

Locks the root account password to prevent password-based root logins.

> [!NOTE]
> This does not remove administrative access for users who already have valid sudo privileges. Users may still be able to gain a root shell through tools such as `sudo su` or `sudo -i`.

## Requirements

- Bash 4.0 or newer
- Root privileges
- `usermod`

## Usage

From the repository root:

```bash
sudo ./hardening/Root\ Locker/root-locker.bash
```

OR from the script directory:

```bash
sudo ./root-locker.bash
```

## Verify

Check the root account state with:

```bash
sudo passwd -S root
```

The second field in the output shows the account status. `L` means the password is locked.

You can also confirm sudo access from a non-root administrative account:

```bash
sudo -v
```

## Tested On

- Ubuntu 24.04, 22.04, 20.04
- Debian 11, 10, 9

## Version History

See [CHANGELOG.md](CHANGELOG.md).
