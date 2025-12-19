# certbot-dns-hetzner-script-hook
Bash scripts to work as a hook for certbot with DNS challenge utilizing the Hetzner Cloud API for DNS.

A Bash script set to automate Let’s Encrypt DNS-01 challenges using Hetzner Cloud DNS.
Supports multiple domains, subdomains, and wildcards, with automatic zone detection.

## Features

* Works with Hetzner Cloud DNS API (not the old DNS API).
* Automatically detects the correct zone for each domain.
* Handles subdomains and wildcards.
* No Python dependencies — pure Bash.

## Requirements

* bash (4+)
* curl
* jq
* certbot

## Installation

```
# Clone the repository
git clone https://github.com/WarpinWolf/certbot-dns-hetzner-hook.git
cd certbot-dns-hetzner-hook

# Copy the example config and edit
cp config.example.sh config.sh
nano config.sh   # set your HCLOUD_API_TOKEN

# Make scripts executable
chmod +x *.sh
```

## Configuration

`config.sh` contains:

```
HCLOUD_API_TOKEN="YOUR_CLOUD_API_TOKEN"  # Hetzner Cloud API token
TXT_COMMENT="certbot-hetzner"            # optional comment
TTL=60                                   # TXT record TTL in seconds
TMP_DIR="/tmp/certbot-hetzner"           # temporary file storage
mkdir -p "$TMP_DIR"
```

# Usage with Certbot

```
certbot certonly \
 --manual \
 --preferred-challenges dns \
 --manual-auth-hook /path/to/auth-hook.sh \
  --manual-cleanup-hook /path/to/cleanup-hook.sh \
  -d example.com -d '*.sub.example.com'
```

### Notes
* For __wildcard domains__, the script creates `_acme-challenge` relative to the zone.
* For __subdomains__ (e.g., sub.example.com), the script creates `_acme-challenge.sub` so that Hetzner resolves `_acme-challenge.sub.example.com`.
* Automatic zone detection ensures the correct zone is used even for CNAMEs.

```
certbot renew \
 --manual \
 --manual-auth-hook /path/to/auth-hook.sh \
 --manual-cleanup-hook /path/to/cleanup-hook.sh
```

## Testing without Certbot

You can simulate the hooks locally:

```
export CERTBOT_DOMAIN="sub.example.com"
export CERTBOT_VALIDATION="dummy-value"

./auth-hook.sh
# verify DNS:
dig TXT _acme-challenge.sub.example.com @1.1.1.1
./cleanup-hook.sh
```
## License
GPLv3 License — see LICENSE.
Free to use, modify, and distribute.
