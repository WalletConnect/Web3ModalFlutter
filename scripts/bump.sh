#!/bin/bash

PUBSPEC_FILE=pubspec.yaml
EXAMPLE_PUBSPEC_FILE=example/pubspec.yaml

FILE_VALUE=$(echo | grep "^version: " $PUBSPEC_FILE)
arrIN=(${FILE_VALUE//:/ })
VERSION=${arrIN[1]}

awk -F": " -v newval="$VERSION" 'BEGIN{OFS=FS} $1=="version"{$2=newval}1' $EXAMPLE_PUBSPEC_FILE > "$EXAMPLE_PUBSPEC_FILE.tmp" && mv "$EXAMPLE_PUBSPEC_FILE.tmp" $EXAMPLE_PUBSPEC_FILE

sh scripts/build.sh

VERSION_FILE_VALUE=`cat lib/version.dart`
NEW_VERSION=`echo $VERSION_FILE_VALUE | sed "s/[^']*'\([^']*\)'.*/\1/"`

echo 'Setting version '$NEW_VERSION' on example apps'

cd example/ios

agvtool new-marketing-version $NEW_VERSION
agvtool next-version -all

cd ..
cd ..

cd example/android

# Set versionName on gradle.properties
awk -F"=" -v newval="$NEW_VERSION" 'BEGIN{OFS=FS} $1=="versionName"{$2=newval}1' gradle.properties > gradle.properties.tmp && mv gradle.properties.tmp gradle.properties

# Increment versionCode (build number) on gradle.properties
awk -F"=" 'BEGIN{OFS=FS} $1=="versionCode"{$2=$2+1}1' gradle.properties > gradle.properties.tmp && mv gradle.properties.tmp gradle.properties


