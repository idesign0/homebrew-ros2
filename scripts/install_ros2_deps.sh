#!/bin/bash
set -e

DISTRO=${1:-jazzy}

REPO="https://raw.githubusercontent.com/idesign0/ros2_macOS"
BASE_URL="$REPO/$DISTRO/brew-packages"

echo "📦 Installing ROS 2 dependencies for: $DISTRO"

# Temp working dir
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download files
curl -sSL "$BASE_URL/matched_packages.txt" -o matched_packages.txt
curl -sSL "$BASE_URL/install_brew_packages.sh" -o install_brew_packages.sh

# Make executable
chmod +x install_brew_packages.sh

# Run installer
./install_brew_packages.sh matched_packages.txt

echo "✅ Dependencies installed for $DISTRO"

# Cleanup
cd ~
rm -rf "$TMP_DIR"
