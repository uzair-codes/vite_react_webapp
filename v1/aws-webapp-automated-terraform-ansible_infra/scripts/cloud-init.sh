#!/bin/bash
#====================================
# Author: Uzair Shah
# Date:  October 1, 2025
# Purpose: Fully automate deployment of a web app (React portfolio) on EC2 instances 
#          launched by an Auto Scaling Group (ASG).
# How to use:
#  - Replace <GITHUB_USER> in GITHUB_REPO with your GitHub username or repo URL.
#  - Copy & paste this entire script into Launch Template → Advanced Details → User data.
#  - Update your Auto Scaling Group to use the new Launch Template version.
#  - Every new EC2 instance launched by the ASG will self-provision using this script
#    and automatically register as healthy behind your Application Load Balancer.
#===================================

set -xe  # Exit immediately if a command fails (-e), and print commands as they run (-x)
export DEBIAN_FRONTEND=noninteractive  # export DEBIAN_FRONTEND=noninteractive before apt upgrades to avoid blocking prompts during apt upgrade.

#---------------------------
# LOGGING SETUP
#---------------------------
LOGFILE=/var/log/user-data.log
exec > >(tee -a ${LOGFILE}) 2>&1
# Redirects all script output (stdout & stderr) to both console & log file.
# This is very helpful for debugging when something goes wrong — check /var/log/user-data.log.

# -------------------------
# Quick helper
# -------------------------
retry() {
  local n=0
  local max=5
  local delay=5
  until "$@" ; do
    n=$((n+1))
    if [ $n -ge $max ]; then
      echo "Command failed after $n attempts: $*" >&2
      return 1
    fi
    echo "Retrying $* ($n/$max) ..."
    sleep $delay
  done
  return 0
}

#---------------------------
# SYSTEM UPDATE & ESSENTIALS
#---------------------------
apt-get update -y 
# Avoid interactive prompts during package upgrades
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Install common dependencies
apt-get install -y curl git build-essential ca-certificates

#---------------------------
# INSTALL NODE.JS (v18)
#---------------------------
# Download & run NodeSource setup script, then install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

#---------------------------
# INSTALL & ENABLE NGINX
#---------------------------
apt-get install -y nginx
systemctl enable nginx  # Make sure Nginx auto-starts on reboot
systemctl start nginx

#---------------------------
# INSTALL AMAZON SSM AGENT
# --------------------------

#---------------------------
# VARIABLES (CUSTOMIZE IF NEEDED)
#---------------------------
GITHUB_REPO="https://github.com/uzair-codes/personal-portfolio.git"  # <-- Change this
APP_DIR="/opt/personal-portfolio"  # Directory where app will be stored
WEBROOT="/var/www/personal-portfolio"

#---------------------------
# CLONE APP REPOSITORY
#---------------------------
# make git clone idempotent (if a folder exists, pull instead of failing)
if [ -d "${APP_DIR}/.git" ]; then
  cd "${APP_DIR}"
  retry git pull || { echo "git pull failed"; exit 1; }
else
  rm -rf "${APP_DIR}"
  retry git clone "${GITHUB_REPO}" "${APP_DIR}" || { echo "git clone failed"; exit 1; }
fi

cd ${APP_DIR}

#---------------------------
# CREATE 1GB SWAP TO AVOID MEMORY ISSUES
#---------------------------
SWAPFILE="/swapfile"
if [ ! -f $SWAPFILE ]; then
  fallocate -l 1G $SWAPFILE
  chmod 600 $SWAPFILE
  mkswap $SWAPFILE
  swapon $SWAPFILE
  echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
fi

#---------------------------
# INSTALL DEPENDENCIES & BUILD
#---------------------------
if [ -f package-lock.json ]; then
   # deterministic install (requires package-lock.json)
   npm ci --unsafe-perm
else
   npm install --unsafe-perm
fi

npm run build  # Build production-optimized React static files

#---------------------------
# DEPLOY TO WEBROOT
#---------------------------
rm -rf "${WEBROOT}"
mkdir -p "${WEBROOT}"
cp -r build/* "${WEBROOT}"
chown -R www-data:www-data "${WEBROOT}" # Set correct permissions for Nginx

#---------------------------
# NGINX CONFIGURATION
#---------------------------
# Replace default config with a custom one to serve React app
cat > /etc/nginx/sites-available/personal-portfolio <<'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/personal-portfolio;
    index index.html;

    # React apps require serving index.html for unknown routes (SPA fallback)
    location / {
        try_files $uri /index.html;
    }

    # Serve static assets correctly   
    location ~* \.(?:css|js|jpg|jpeg|gif|png|svg|ico|woff2?|ttf|map)$ {
    root /var/www/personal-portfolio;
    access_log off;
    log_not_found off;
    expires 30d;
    add_header Cache-Control "public, must-revalidate";
    }

  
}
EOF

# Enable new site config & disable default one
ln -fs /etc/nginx/sites-available/personal-portfolio /etc/nginx/sites-enabled/personal-portfolio
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration & reload service
nginx -t && systemctl restart nginx

# -------------------------
# Verify app is responding locally
# -------------------------
# Try a few times: if it fails, fail the script (ASG will mark instance unhealthy)
retry curl --fail --silent http://localhost/ || { echo "Local HTTP check failed"; exit 1; }

#---------------------------
# FINAL LOG
#---------------------------
echo "Deployment finished successfully at $(date)" >> ${LOGFILE}
