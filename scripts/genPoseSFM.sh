#!/bin/sh

fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")

. ${scriptDir}/include.sh
captureId=${CAPTURE_ID}
startFrame=1
endFrame=450
nasDataDir=/ext/input/nas-mount/data
framesDir=/ext/input/frames
outputBaseDir=/ext/output/alice/${captureId}
sensorsDb=/opt/AliceVision_bundle/share/aliceVision/cameraSensors.db 
currentFrame=${startFrame}
cpuOnly=1
describerTypes=sift,akaze
while test ${currentFrame} -le ${endFrame}; do
  echo ${currentFrame}
  addCameraMeta "${nasDataDir}" "${framesDir}" "${captureId}" "${currentFrame}"
  frameOutputDir=${outputBaseDir}/frame${currentFrame}
  mkdir -p ${frameOutputDir}
  initSfmPath=${frameOutputDir}/init.sfm
  incrementalSfmPath=${frameOutputDir}/incremental.sfm
  aliceVision_cameraInit \
    --imageFolder ${framesDir}/${captureId}/genUsable/usable/frame${currentFrame} \
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
  aliceVision_incrementalSfM \
    --input=${initSfmPath} \
    --output=${incrementalSfmPath} \
    --featuresFolder=${featuresPath} \
    --describerTypes=${describerTypes} \
    --matchesFolder=${matchesPath}
  currentFrame=$(expr ${currentFrame} + 1)
done
