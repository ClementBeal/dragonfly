#!/bin/bash


# --- Configuration ---
CURRENT_FOLDER=$(pwd)
APP_NAME="dragonfly"  # Replace with your app's name
APP_VERSION="0.0.1"       # Replace with your app's version


# --- Main Script ---

cd apps/dragonfly_browser

puro flutter build apk --split-per-abi
mv build/app/outputs/apk/release/app-armeabi-v7a-release.apk $CURRENT_FOLDER/dist/Dragonfly-$APP_VERSION-android-armeabi-v7a-release.apk
mv build/app/outputs/apk/release/app-arm64-v8a-release.apk $CURRENT_FOLDER/dist/Dragonfly-$APP_VERSION-android-arm64-v8a-release.apk
mv build/app/outputs/apk/release/app-x86_64-release.apk $CURRENT_FOLDER/dist/Dragonfly-$APP_VERSION-android-x86_64.apk

puro flutter build apk 
mv build/app/outputs/apk/release/app-release.apk $CURRENT_FOLDER/dist/Dragonfly-$APP_VERSION-android-all.apk

echo "Done!"