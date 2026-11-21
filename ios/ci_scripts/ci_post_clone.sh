#!/bin/sh
set -eu

cd "${CI_PRIMARY_REPOSITORY_PATH:?Missing Xcode Cloud repository path}"

flutter_version=3.47.7
flutter_sdk_dir="$HOME/flutter-$flutter_version"
git clone --depth 1 --branch "$flutter_version" https://github.com/flutter/flutter.git "$flutter_sdk_dir"
flutter="$flutter_sdk_dir/bin/flutter"

"$flutter" precache --ios
# Xcode Cloud resolves local Swift packages before running the scheme's build scripts.
"$flutter" pub get
"$flutter" build ios --release --config-only --no-codesign --no-pub

manifest=ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift
if [ ! -s "$manifest" ]; then
  printf 'Flutter did not generate the Swift package manifest: %s\n' "$manifest" >&2
  exit 1
fi
