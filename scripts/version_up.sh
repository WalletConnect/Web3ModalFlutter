#!/bin/bash

PUBSPEC_FILE=pubspec.yaml
EXAMPLE_PUBSPEC_FILE=example/pubspec.yaml

FILE_VALUE=$(echo | grep "^version: " $PUBSPEC_FILE)
PARTS=(${FILE_VALUE//:/ })
FULL_VERSION=${PARTS[1]}
VERSION_NUMBER=(${FULL_VERSION//-/ })

echo $FULL_VERSION
echo $VERSION_NUMBER

awk -F": " -v newval="$VERSION_NUMBER" 'BEGIN{OFS=FS} $1=="version"{$2=newval}1' $EXAMPLE_PUBSPEC_FILE > "$EXAMPLE_PUBSPEC_FILE.tmp" && mv "$EXAMPLE_PUBSPEC_FILE.tmp" $EXAMPLE_PUBSPEC_FILE

sh scripts/build.sh

echo 'Setting version '$VERSION_NUMBER' on example apps'

cd example/ios

agvtool new-marketing-version $VERSION_NUMBER
agvtool next-version -all

cd ..
cd ..

cd example/android

# Set versionName on gradle.properties
awk -F"=" -v newval="$VERSION_NUMBER" 'BEGIN{OFS=FS} $1=="versionName"{$2=newval}1' gradle.properties > gradle.properties.tmp && mv gradle.properties.tmp gradle.properties

# Increment versionCode (build number) on gradle.properties
awk -F"=" 'BEGIN{OFS=FS} $1=="versionCode"{$2=$2+1}1' gradle.properties > gradle.properties.tmp && mv gradle.properties.tmp gradle.properties

cd ..
cd ..

flutter pub publish --dry-run