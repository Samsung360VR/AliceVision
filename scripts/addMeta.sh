#!/bin/sh

fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")

. ${scriptDir}/include.sh
imagesFolder=/ext/input/frames/${CAPTURE_ID}/rig.a
addCameraMeta2 ${imagesFolder}
