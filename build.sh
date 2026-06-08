#!/bin/bash
set -e

APP_NAME="Cocaine"
BUILD_DIR=".build/release"
APP_BUNDLE="/Applications/${APP_NAME}.app"

echo "Building ${APP_NAME}..."
cd "$(dirname "$0")"

swift build -c release

# Create .app bundle
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "$APP_BUNDLE/Contents/MacOS/"

cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Cocaine</string>
    <key>CFBundleDisplayName</key>
    <string>Cocaine</string>
    <key>CFBundleIdentifier</key>
    <string>com.baptistec.cocaine</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>Cocaine</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
PLIST

echo "Installed to ${APP_BUNDLE}"
