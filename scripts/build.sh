#!/bin/bash

echo ' 🔄 Updating dependencies...'
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

cd ios

pod install

cd ..

cd example

echo ' ⬇️ Getting dependencies...'
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

cd ios

pod install
