#!/bin/bash

if [ $# -eq 0 ];
then
  echo "------------------------------------------------------------------------------------"
  echo "$0: Missing argument. Please run this script by passing a valid projectId as argument"
  echo "------------------------------------------------------------------------------------"
  exit 1
else
  cd example
  flutter run --dart-define=PROJECT_ID=$1 -v
fi