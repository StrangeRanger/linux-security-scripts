# Nginx Cloudflare Real IP

Configures Nginx to trust Cloudflare's IP ranges and use the `CF-Connecting-IP` header for the true client IP.

## Requirements

- Bash 4.0 or newer
- Administrative access through `sudo`
- Nginx installed with the HTTP Real IP module available
- An existing `/etc/nginx/conf.d` directory included inside the active Nginx `http` block
- A systemd-based system with an `nginx` service
- `curl`
- Internet access

## Usage

From the repository root:

```bash
./hardening/Nginx\ Cloudflare\ Real\ IP/nginx-cloudflare-realip.bash
```

OR from the script directory:

```bash
./nginx-cloudflare-realip.bash
```

The script prompts before continuing and uses `sudo` for configuration changes, Nginx checks, and the service restart. If the configuration file already exists, it also asks for confirmation before overwriting it.

## Execution Summary

- Downloads current Cloudflare IPv4 and IPv6 ranges from Cloudflare.
- Stops if either download fails or returns an empty list.
- Writes `/etc/nginx/conf.d/cloudflare-realip.conf` with a `set_real_ip_from` directive for each range.
- Sets `real_ip_header` to `CF-Connecting-IP` and `real_ip_recursive` to `off`.
- Runs `nginx -T` to validate and retrieve the active configuration.
- Confirms that Nginx includes the generated configuration file.
- Restarts Nginx to apply the changes.

## Files and Directories

System paths used by the script include:

- `/etc/nginx/conf.d`
- `/etc/nginx/conf.d/cloudflare-realip.conf`

If Nginx does not include the generated file, the script stops with instructions to add the following inside the active Nginx `http` block:

```nginx
include /etc/nginx/conf.d/*.conf;
```

The file can also be included directly. Rerun the configuration checks before restarting Nginx.

## Safety Notes

- Existing configuration is overwritten only after confirmation, but the script does not create a backup or automatically restore it if validation or restart fails.
- The script configures trusted proxies; it does not restrict direct origin access through firewall rules.
- Cloudflare IP ranges are fetched on each run. The script does not schedule automatic updates.

## Verify

Check the Nginx configuration:

```bash
sudo nginx -t
```

Review the generated trusted proxy configuration:

```bash
sudo cat /etc/nginx/conf.d/cloudflare-realip.conf
```

Confirm that Nginx includes the file:

```bash
sudo nginx -T 2>&1 | grep -Fx '# configuration file /etc/nginx/conf.d/cloudflare-realip.conf:'
```

Check Nginx service status:

```bash
sudo systemctl status nginx
```

## Version History

See [CHANGELOG.md](CHANGELOG.md).
