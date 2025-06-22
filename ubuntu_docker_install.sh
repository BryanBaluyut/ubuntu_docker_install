#!/bin/bash

# This script automates the installation of Docker and Docker Compose on Ubuntu.
# It follows the official Docker installation guide.

set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Starting Docker Installation Script ---"

# 1. UNINSTALL OLDER VERSIONS
echo "[Step 1/6] Uninstalling old Docker versions..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    if dpkg -l | grep -q $pkg; then
        echo "Removing existing package: $pkg"
        sudo apt-get remove -y $pkg
    fi
done
sudo apt-get autoremove -y
echo "Old versions removed."
echo "----------------------------------------"

# 2. SET UP THE REPOSITORY
echo "[Step 2/6] Setting up Docker's APT repository..."
# Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
if [ -f /etc/apt/keyrings/docker.asc ]; then
    sudo rm /etc/apt/keyrings/docker.asc
fi
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "Repository setup complete."
echo "----------------------------------------"

# 3. INSTALL DOCKER ENGINE
echo "[Step 3/6] Installing Docker Engine, CLI, and plugins..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "Docker Engine installed."
echo "----------------------------------------"

# 4. MANAGE DOCKER AS A NON-ROOT USER (POST-INSTALLATION)
echo "[Step 4/6] Configuring Docker to run without sudo..."
# Create the docker group if it doesn't exist
if ! getent group docker > /dev/null; then
    sudo groupadd docker
    echo "Created 'docker' group."
fi

# Add the current user to the docker group
sudo usermod -aG docker $USER
echo "Added user '$USER' to the 'docker' group."
echo "----------------------------------------"

# 5. VERIFY INSTALLATION
echo "[Step 5/6] Verifying Docker installation..."
# Run the hello-world container to confirm
# Note: We need to use 'newgrp' or log out/in for the group change to apply.
# For script verification, we'll temporarily use newgrp to run the docker command.
echo "Running 'hello-world' container. You may be prompted for your password."
newgrp docker <<EOT
docker run hello-world
EOT
echo "Verification complete. 'hello-world' ran successfully."
echo "----------------------------------------"


# 6. FINAL MESSAGE
echo "[Step 6/6] Installation Complete!"
echo ""
echo "--- Docker and Docker Compose have been successfully installed. ---"
echo ""
echo "IMPORTANT: To apply the new group membership for '$USER', you need to either:"
echo "1. Log out and log back in."
echo "2. Or, for the current terminal session, type: newgrp docker"
echo ""
echo "You can verify the Docker Compose version with: docker compose version"
echo ""
