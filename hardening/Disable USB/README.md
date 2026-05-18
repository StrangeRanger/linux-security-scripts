# Disable USB

Experimental script intended to disable the `usb-storage` kernel module.

This script appears to be early-stage work. It currently checks whether the `usb_storage` module is loaded and whether `usb-storage` appears loadable, but the disabling action is not fully implemented yet.

## Requirements

- Bash 4.0 or newer
- Root privileges
- `lsmod`
- `modprobe`

## Usage

Run the script from the repository root:

```bash
sudo ./hardening/Disable\ USB/disable-usb.bash
```

The script prompts before checking the USB storage module.

## Current Behavior

- Verifies it is running with root privileges.
- Checks whether the `usb_storage` kernel module is currently loaded.
- Checks whether `usb-storage` appears loadable through `modprobe -n -v usb-storage`.
- Prints status messages.

## Intended Behavior

The script defines `/etc/modprobe.d/usb-storage.conf` as the target configuration file and includes a configurable method named `C_USB_DISABLE_METHOD`.

The available method names documented in the script are:

- `disable`
- `blacklist`

The current default is:

```bash
C_USB_DISABLE_METHOD="disable"
```

## Safety Notes

- Do not treat this script as production-ready yet.
- Disabling USB storage can interfere with removable media, backup workflows, provisioning, and recovery processes.
- Confirm that any required keyboard, console, storage, or recovery workflows do not depend on USB storage before completing this feature.

## Verify

Check whether the USB storage module is loaded:

```bash
lsmod | grep -i usb_storage
```

Check how `modprobe` would handle the module:

```bash
modprobe -n -v usb-storage
```

## Tested On

Not documented yet.

## Version History

See [CHANGELOG.md](CHANGELOG.md).
