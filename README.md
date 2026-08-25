# byfox

Static website for remote router setup and support services.

## Files

- `index.html` - landing page
- `offer.html` - public offer
- `privacy.html` - privacy policy
- `refund.html` - refund policy
- `styles.css` - theme and layout
- `script.js` - mobile navigation
- `vps/install-vps.sh` - one-click VPS installer with nginx, Let's Encrypt, and HTTPS redirect

## One-click VPS install

Before running the installer, point your domain A record to the VPS IP address.

The installer:

- installs `nginx`, `certbot`, `curl`, and `ca-certificates`
- asks for your domain name
- downloads the latest website files from this repository
- creates an nginx config
- enables the site and restarts nginx
- issues a Let's Encrypt certificate
- enables automatic redirect from `http` to `https`

Run with domain prompt:

```bash
curl -fsSL "https://raw.githubusercontent.com/kzolotarev95/byfox/main/vps/install-vps.sh?v=$(date +%s)" | sudo bash
```

Or run with domain passed explicitly:

```bash
curl -fsSL "https://raw.githubusercontent.com/kzolotarev95/byfox/main/vps/install-vps.sh?v=$(date +%s)" | sudo bash -s -- your-domain.com
```

Optional: pass your email for Let's Encrypt registration:

```bash
LETSENCRYPT_EMAIL=you@example.com curl -fsSL "https://raw.githubusercontent.com/kzolotarev95/byfox/main/vps/install-vps.sh?v=$(date +%s)" | sudo -E bash -s -- your-domain.com
```

After install, open:

```bash
https://your-domain.com
```

## Notes

- Tested for Debian/Ubuntu style VPS servers with `apt`.
- Port `80` and port `443` must be open for successful HTTPS setup.
