#!/bin/bash

# echo ' 🔄 Updating dependencies...'
# flutter clean
# flutter pub get
# flutter pub run build_runner build --delete-conflicting-outputs

# cd ios

# pod install

# cd ..

# cd example

# echo ' ⬇️ Getting dependencies...'
# flutter clean
# flutter pub get
# flutter pub run build_runner build --delete-conflicting-outputs

# cd ios

# pod install


# Get app version from file
# PUBSPEC_FILE=/Users/alfreedom/Development/WalletConnect/Web3ModalFlutter/pubspec.yaml
EXAMPLE_PUBSPEC_FILE=/Users/alfreedom/Development/WalletConnect/Web3ModalFlutter/example/pubspec.yaml

FILE_VALUE=$(echo | grep "^version: " $EXAMPLE_PUBSPEC_FILE)
PARTS=(${FILE_VALUE//:/ })
FULL_VERSION=${PARTS[1]}
VERSION_NUMBER=(${FULL_VERSION//-/ })

# Build ios app with flutter
echo "flutter build ios --build-name $VERSION_NUMBER --dart-define=\"PROJECT_ID=$PROJECT_ID\" --config-only --release"