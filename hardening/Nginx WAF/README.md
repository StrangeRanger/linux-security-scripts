# Nginx WAF

> [!CAUTION]
> Script is currently in beta.

Installs and configures ModSecurity with the OWASP Core Rule Set for Nginx.

## Requirements

- Bash 4.0 or newer
- Root privileges
- Nginx 1.24.0 or newer, installed and available in `PATH`
- A Debian/Ubuntu-style system with `apt-get` and `dpkg`
- Internet access

The script installs required packages such as:

- `git`
- `autoconf`
- `automake`
- `build-essential`
- `libcurl4-openssl-dev`
- `libgeoip-dev`
- `libpcre2-dev`
- `libtool`
- `libxml2-dev`
- `libyajl-dev`
- `pkgconf`
- `wget`
- `zlib1g-dev`

It may install additional development packages depending on how the installed Nginx binary was built.

## Usage

From the repository root:

```bash
./hardening/Nginx\ WAF/nginx-waf.bash
```

OR from the script directory:

```bash
./nginx-waf.bash
```

## Execution Summary

- Detects the installed Nginx version and configure arguments.
- Installs missing build dependencies through `apt-get`.
- Clones, builds, and installs ModSecurity v3.
- Clones the ModSecurity Nginx connector.
- Downloads matching Nginx source for the installed Nginx version.
- Builds the ModSecurity dynamic module for Nginx.
- Installs `ngx_http_modsecurity_module.so` into the Nginx modules path.
- Writes module loading configuration under `/etc/nginx/modules-available`.
- Enables the module under `/etc/nginx/modules-enabled`.
- Creates `/etc/nginx/modsec`.
- Enables ModSecurity rule engine mode.
- Clones and configures the OWASP Core Rule Set.
- Writes `/etc/nginx/modsec/main.conf`.
- Runs `nginx -t`.
- Restarts Nginx.

## Files and Directories

System paths used by the script include:

- `/etc/nginx/modules-available`
- `/etc/nginx/modules-enabled`
- `/etc/nginx/modsec`
- `/etc/nginx/modsec/modsecurity.conf`
- `/etc/nginx/modsec/main.conf`

The script also creates or reuses build directories in the current working directory:

- `ModSecurity`
- `ModSecurity-nginx`
- `nginx-VERSION`
- `nginx-VERSION.tar.gz`

## Safety Notes

- Review local Nginx packaging conventions before running it on systems with custom Nginx builds.
- The OWASP Core Rule Set can block legitimate traffic until tuned for the application.
- Existing local changes in reused `ModSecurity`, `ModSecurity-nginx`, or CRS clone directories may affect the run.

## Verify

Check the Nginx configuration:

```bash
sudo nginx -t
```

Check Nginx service status:

```bash
sudo systemctl status nginx
```

Confirm the ModSecurity module load file exists:

```bash
ls -l /etc/nginx/modules-enabled/50-modsecurity.conf
```

## Tested On

- Ubuntu 24.04
- Nginx 1.24.0 and later

## Version History

See [CHANGELOG.md](CHANGELOG.md).
