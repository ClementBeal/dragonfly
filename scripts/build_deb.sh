#!/bin/bash


# --- Configuration ---
CURRENT_FOLDER=$(pwd)
APP_NAME="dragonfly"  # Replace with your app's name
APP_VERSION="0.0.1"       # Replace with your app's version

# --- Functions ---

function build_flutter_app() {
  local ARCHITECTURE="$1"
  echo "Building Flutter application"
  puro flutter build linux --release || exit 1  # Exit if build fails
}

function create_deb_package() {
  local ARCHITECTURE="$1"
  local BUILD_DIR="build/linux/$ARCHITECTURE/release"
  local DEB_FILE="$APP_NAME_$APP_VERSION_$ARCHITECTURE.deb"
  local DEBIAN_DIR="$BUILD_DIR/DEBIAN"


  echo "Creating DEB package for $ARCHITECTURE..."
  cd "$BUILD_DIR"
  tar -cvJf ../data.tar.xz *
  cd ..
  mkdir -p "DEBIAN" || exit 1 

  cat > "DEBIAN/control" <<EOF
Package: $APP_NAME
Version: $APP_VERSION
Architecture: amd64
Maintainer: Clement Beal <your.email@example.com>
Depends: libsqlite3-dev
Description: A web browser made in Flutter
EOF

  dpkg-deb --build . dragonfly.deb
  
  mv "dragonfly.deb" $CURRENT_FOLDER/dist/Dragonfly-$APP_VERSION-linux-x64.deb
  mv "data.tar.xz" $CURRENT_FOLDER/dist/Dragonfly-$APP_VERSION-linux-x64.tar.xz

  echo "DEB package created successfully"
}

# --- Main Script ---


# linux-amd64 || linux-x64

cd apps/dragonfly_browser
build_flutter_app "linux-x64"
create_deb_package "x64"

echo "Done!"