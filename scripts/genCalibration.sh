#!/bin/sh

fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")

. ${scriptDir}/include.sh
setupEnv

captureId=${CALIBRATION_CAPTURE_ID}
startFrame=1
endFrame=1
framesDir=/ext/input/frames
outputBaseDir=${calibrationBaseDir}/${captureId}
currentFrame=${startFrame}
cpuOnly=0

frameInputDir=${framesDir}/${captureId}/genUsable/usable
frameStagingDir=${outputBaseDir}/frames/rig
if test ! -d ${frameStagingDir}; then
  c=0
  for i in `ls -rt ${frameInputDir}`; do
    src=${frameInputDir}/${i}
    dst=${frameStagingDir}/${c}
    runCmd "mkdir -p ${dst}"
    p=0
    for j in `ls -rt ${src}`; do
      ext=$(echo ${j} | cut -f2 -d.)
      imgSrc=${src}/${j}
      imgDst=${dst}/${p}.${ext}
      runCmd "cp ${imgSrc} ${imgDst}"
      p=$(expr ${p} + 1)
    done
    addCameraMeta3 "${dst}"
    c=$(expr ${c} + 1)
  done
fi

resultsDir=${outputBaseDir}/results
mkdir -p ${resultsDir}
initSfmPath=${resultsDir}/rig.sfm
if test ! -f ${initSfmPath}; then
  runCmd "aliceVision_cameraInit \
    --defaultCameraModel=${cameraModel} \
    --imageFolder ${frameStagingDir} \
    --output=${initSfmPath} \
    --sensorDatabase=${sensorsDb} \
    --verboseLevel=${verboseLevel}"
fi  

featuresPath=${resultsDir}/features
mkdir -p ${featuresPath}
runCmd "aliceVision_featureExtraction \
  --input=${initSfmPath} \
  --output=${featuresPath} \
  --forceCpuExtraction=${cpuOnly} \
  --describerTypes=${describerTypes} \
  --describerPreset=high \
  --verboseLevel=${verboseLevel}"

imagePairsFile=${resultsDir}/pairs.txt
runCmd "aliceVision_imageMatching \
  --input=${initSfmPath} \
  --featuresFolders=${featuresPath} \
  --tree=${AV_BUNDLE}/share/aliceVision/vlfeat_K80L3.SIFT.tree \
  --nbMatches=0 \
  --maxDescriptors=0 \
  --output=${imagePairsFile}"

matchesPath=${resultsDir}/matches
mkdir -p ${matchesPath}
runCmd "aliceVision_featureMatching \
  --input=${initSfmPath} \
  --output=${matchesPath} \
  --featuresFolder=${featuresPath} \
  --describerTypes=${describerTypes} \
  --guidedMatching=1 \
  --matchFilePerImage=1 \
  --verboseLevel=${verboseLevel}"

incrementalSfmPath=${resultsDir}/incremental.sfm
viewPosesSfmPath=${resultsDir}/viewAndPoses.sfm
runCmd "aliceVision_incrementalSfM \
  --input=${initSfmPath} \
  --output=${incrementalSfmPath} \
  --featuresFolder=${featuresPath} \
  --describerTypes=${describerTypes} \
  --matchesFolder=${matchesPath} \
  --outputViewsAndPoses=${viewPosesSfmPath} \
  --verboseLevel=${verboseLevel}"
