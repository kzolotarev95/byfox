# byfox

Static website for remote router setup and support services.

## Files

- `index.html` - landing page
- `offer.html` - public offer
- `privacy.html` - privacy policy
- `refund.html` - refund policy
- `styles.css` - theme and layout
- `script.js` - mobile navigation
- `vps/install-vps.sh` - one-click VPS installer with nginx setup

## One-click VPS install

Before running the installer, point your domain A record to the VPS IP address.

The installer:

- installs `nginx`, `curl`, and `ca-certificates`
- asks for your domain name
- downloads the latest website files from this repository
- creates an nginx config
- enables the site and restarts nginx

Run:

```bash
curl -fsSL "https://raw.githubusercontent.com/kzolotarev95/byfox/main/vps/install-vps.sh?v=$(date +%s)" | sudo bash
```

After install, open:

```bash
http://your-domain.com
```

## Notes

- Tested for Debian/Ubuntu style VPS servers with `apt`.
- SSL is not configured by this script yet.
