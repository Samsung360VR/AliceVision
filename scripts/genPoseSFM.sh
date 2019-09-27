#!/bin/sh

fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")

. ${scriptDir}/include.sh
setupEnv

captureId=${CAPTURE_ID}
startFrame=1
endFrame=1
framesDir=/ext/input/frames
outputBaseDir=${calibrationBaseDir}/${captureId}
currentFrame=${startFrame}
cpuOnly=0

frameInputDir=${framesDir}/${captureId}/genUsable/usable
addCameraMeta2 "${frameInputDir}" 1 0
frameDirPrefix=frame
while test ${currentFrame} -le ${endFrame}; do
  echo ${currentFrame}
  frameOutputDir=${outputBaseDir}/${frameDirPrefix}${currentFrame}
  mkdir -p ${frameOutputDir}
  initSfmPath=${frameOutputDir}/init.sfm
  runCmd "aliceVision_cameraInit \
    --imageFolder ${frameInputDir}/${frameDirPrefix}${currentFrame} \
    --output=${initSfmPath} \
    --sensorDatabase=${sensorsDb} \
    --verboseLevel=${verboseLevel}"
  featuresPath=${frameOutputDir}/features
  mkdir -p ${featuresPath}
  runCmd "aliceVision_featureExtraction \
    --input=${initSfmPath} \
    --output=${featuresPath} \
    --forceCpuExtraction=${cpuOnly} \
    --describerTypes=${describerTypes} \
    --describerPreset=high \
    --verboseLevel=${verboseLevel}"
  matchesPath=${frameOutputDir}/matches
  mkdir -p ${matchesPath}
  runCmd "aliceVision_featureMatching \
    --input=${initSfmPath} \
    --output=${matchesPath} \
    --featuresFolder=${featuresPath} \
    --describerTypes=${describerTypes} \
    --guidedMatching=1 \
    --matchFilePerImage=1 \
    --verboseLevel=${verboseLevel}"
  incrementalSfmPath=${frameOutputDir}/incremental.sfm
  runCmd "aliceVision_incrementalSfM \
    --input=${initSfmPath} \
    --output=${incrementalSfmPath} \
    --featuresFolder=${featuresPath} \
    --describerTypes=${describerTypes} \
    --matchesFolder=${matchesPath} \
    --verboseLevel=${verboseLevel}"
  globalSfmPath=${frameOutputDir}/globalSfm
  runCmd "aliceVision_globalSfM \
    --input=${initSfmPath} \
    --output=${globalSfmPath} \
    --outSfMDataFilename=global.sfm \
    --featuresFolder=${featuresPath} \
    --describerTypes=${describerTypes} \
    --matchesFolder=${matchesPath} \
    --verboseLevel=${verboseLevel}"
  currentFrame=$(expr ${currentFrame} + 1)
done
