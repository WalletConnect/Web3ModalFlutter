#!/bin/bash

if [ $# -eq 0 ];
then
  echo "------------------------------------------------------------------------------------"
  echo "$0: Missing argument. Please run this script by passing a valid projectId as argument"
  echo "------------------------------------------------------------------------------------"
  exit 1
else
  sh build.sh

  FILE_VALUE=`cat lib/version.dart`
  VERSION=`echo $FILE_VALUE | sed "s/[^']*'\([^']*\)'.*/\1/"`
  VNAME=`echo $VERSION | sed "s/+.*//"`
  VBUILD=${VERSION#*+}

  cd example

  flutter build apk --build-name $VNAME --build-number $VBUILD --dart-define='PROJECT_ID=$1'
  flutter build ipa --build-name $VNAME --build-number $VBUILD --dart-define='PROJECT_ID=$1'
fi