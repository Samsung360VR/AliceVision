#!/bin/sh

fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")

. ${scriptDir}/include.sh
captureId=${CAPTURE_ID}
startFrame=1
endFrame=1
nasDataDir=/ext/input/nas-mount/data
framesDir=/ext/input/frames
outputBaseDir=/ext/output/alice/${captureId}
sensorsDb=${AV_BUNDLE}/share/aliceVision/cameraSensors.db 
currentFrame=${startFrame}
cpuOnly=0
numPoses=${NUM_CAMS}
describerTypes=sift,akaze
describerTypes=sift
mergerScript=${AV_DEV}/py/mergeSFM.py

frameInputDir=${framesDir}/${captureId}/genUsable/usable
echo addCameraMeta2 "${frameInputDir}" 1 0
frameDirPrefix=frame
while test ${currentFrame} -le ${endFrame}; do
  echo ${currentFrame}
  frameOutputDir=${outputBaseDir}/${frameDirPrefix}${currentFrame}
  mkdir -p ${frameOutputDir}
  initSfmPath=${frameOutputDir}/init.sfm
  incrementalSfmPath=${frameOutputDir}/incremental.sfm
  aliceVision_cameraInit \
    --imageFolder ${frameInputDir}/${frameDirPrefix}${currentFrame} \
    --output=${initSfmPath} \
    --sensorDatabase=${sensorsDb}
  featuresPath=${frameOutputDir}/features
  mkdir -p ${featuresPath}
  aliceVision_featureExtraction \
    --input=${initSfmPath} \
    --output=${featuresPath} \
    --forceCpuExtraction=${cpuOnly} \
    --describerTypes=${describerTypes} \
    --describerPreset=high
  matchesPath=${frameOutputDir}/matches
  mkdir -p ${matchesPath}
  aliceVision_featureMatching \
    --input=${initSfmPath} \
    --output=${matchesPath} \
    --featuresFolder=${featuresPath} \
    --describerTypes=${describerTypes} \
    --guidedMatching=1
  viewsAndPosesSfmPath=${frameOutputDir}/views-poses.sfm
  aliceVision_incrementalSfM \
    --input=${initSfmPath} \
    --output=${incrementalSfmPath} \
    --outputViewsAndPoses=${viewsAndPosesSfmPath} \
    --featuresFolder=${featuresPath} \
    --describerTypes=${describerTypes} \
    --matchesFolder=${matchesPath}
  currentFrame=$(expr ${currentFrame} + 1)
done
