#!/bin/sh

fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")

. ${scriptDir}/include.sh
captureId=${CAPTURE_ID}
startFrame=1
endFrame=300
nasDataDir=/ext/input/nas-mount/data
framesDir=/ext/input/frames
outputBaseDir=/ext/output/alice/${captureId}
sensorsDb=${AV_BUNDLE}/share/aliceVision/cameraSensors.db 
currentFrame=${startFrame}
cpuOnly=0
numPoses=72
describerTypes=sift,akaze
describerTypes=sift
mergerScript=/usr/src/app/py/mergeSFM.py
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
    --describerTypes=${describerTypes}
#    --describerPreset=high
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
  combinedSfm = ${outputBaseDir}/combined.sfm
  python3 ${mergerScript} --srcSfms ${combinedSfm} ${viewsAndPosesSfmPath} --tgtSfm ${combinedSfm} --numPoses ${numPoses}
  if test $? -eq 0; then
    break
  fi
  currentFrame=$(expr ${currentFrame} + 1)
done
