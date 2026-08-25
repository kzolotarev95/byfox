#!/usr/bin/env bash

set -euo pipefail

REPO_OWNER="kzolotarev95"
REPO_NAME="byfox"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"
WEB_ROOT="/var/www/byfox/public"
NGINX_CONF="/etc/nginx/sites-available/byfox.conf"
FILES=(
  "index.html"
  "offer.html"
  "privacy.html"
  "refund.html"
  "styles.css"
  "script.js"
)
DOMAIN="${1:-${DOMAIN:-}}"

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run this installer with sudo or as root."
    exit 1
  fi
}

require_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "This installer currently supports Debian/Ubuntu based VPS servers only."
    exit 1
  fi
}

trim_value() {
  local value="$1"
  value="${value#http://}"
  value="${value#https://}"
  value="${value%%/*}"
  value="${value#www.}"
  printf "%s" "${value}"
}

ask_domain() {
  local input=""

  if [[ -n "${DOMAIN}" ]]; then
    DOMAIN="$(trim_value "${DOMAIN}")"

    if [[ "${DOMAIN}" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
      return
    fi

    echo "Provided domain is invalid: ${DOMAIN}"
    exit 1
  fi

  if [[ ! -t 1 ]] && [[ ! -e /dev/tty ]]; then
    echo "Interactive domain prompt is unavailable."
    echo "Run the installer like this:"
    echo "curl -fsSL \"${RAW_BASE}/vps/install-vps.sh?v=\$(date +%s)\" | sudo bash -s -- example.com"
    exit 1
  fi

  while true; do
    read -r -p "Enter your domain (example.com): " input < /dev/tty
    input="$(trim_value "${input}")"

    if [[ -z "${input}" ]]; then
      echo "Domain cannot be empty."
      continue
    fi

    if [[ ! "${input}" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
      echo "Please enter a valid domain name."
      continue
    fi

    DOMAIN="${input}"
    return
  done
}

install_packages() {
  export DEBIAN_FRONTEND=noninteractive

  apt-get update
  apt-get install -y nginx curl ca-certificates
}

download_site() {
  mkdir -p "${WEB_ROOT}"

  for file in "${FILES[@]}"; do
    echo "Downloading ${file}..."
    curl -fsSL "${RAW_BASE}/${file}" -o "${WEB_ROOT}/${file}"
  done
}

write_nginx_config() {
  cat > "${NGINX_CONF}" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};

    root ${WEB_ROOT};
    index index.html;

    access_log /var/log/nginx/byfox.access.log;
    error_log /var/log/nginx/byfox.error.log;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header Referrer-Policy strict-origin-when-cross-origin;
}
EOF

  rm -f /etc/nginx/sites-enabled/default
  ln -sf "${NGINX_CONF}" /etc/nginx/sites-enabled/byfox.conf
}

reload_nginx() {
  nginx -t
  systemctl enable nginx
  systemctl restart nginx
}

print_done() {
  echo
  echo "Installation complete."
  echo "Website root: ${WEB_ROOT}"
  echo "Domain: ${DOMAIN}"
  echo "Open: http://${DOMAIN}"
  echo
  echo "If the domain is not opening yet, make sure its DNS A record points to this VPS."
}

main() {
  require_root
  require_apt
  ask_domain
  install_packages
  download_site
  write_nginx_config
  reload_nginx
  print_done
}

main "$@"
