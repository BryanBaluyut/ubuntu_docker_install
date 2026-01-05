#!/bin/bash
set -e

echo "--- Universal Docker Installer ---"

# 1. DETECT PACKAGE MANAGER
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    echo "Detected package manager: APT (Debian/Ubuntu/Mint/Kali)"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    echo "Detected package manager: DNF (Fedora/RHEL 8+)"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    echo "Detected package manager: YUM (CentOS/RHEL 7)"
else
    echo "Error: Unsupported package manager. This script works on apt, dnf, and yum systems."
    exit 1
fi

echo "----------------------------------------"

# 2. REMOVE OLD VERSIONS (Universal)
echo "[Step 1] Removing conflicting old versions..."

if [ "$PKG_MANAGER" == "apt" ]; then
    # Debian/Ubuntu cleanup
    sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc || true
    sudo apt-get autoremove -y || true

elif [ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "yum" ]; then
    # Fedora/CentOS cleanup
    sudo $PKG_MANAGER remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine || true
fi

echo "Cleanup complete."
echo "----------------------------------------"

# 3. INSTALL DOCKER (Using Official Script)
echo "[Step 2] Installing Docker Official..."

# We use the official get-docker.sh script because it handles
# the complex repository logic for every single distro automatically.
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

echo "----------------------------------------"

# 4. POST-INSTALL CONFIGURATION
echo "[Step 3] configuring user permissions..."

# Create group if missing (get-docker usually does this, but safely ensure it)
getent group docker > /dev/null || sudo groupadd docker

# Add current user
sudo usermod -aG docker $USER

echo "----------------------------------------"
echo "Installation Complete!"
echo "Please LOG OUT and log back in to use Docker without sudo."
