#!/bin/sh

fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")

. ${scriptDir}/include.sh
setupEnv

stitchCaptureId=${STITCH_CAPTURE_ID}
calibrationCaptureId=${CALIBRATION_CAPTURE_ID}
if test -z ${calibrationCaptureId}; then
  calibrationCaptureId=${stitchCaptureId}
fi
startFrame=1
endFrame=1
framesDir=/ext/input/frames
currentFrame=${startFrame}
calibrationDir=${calibrationBaseDir}/${calibrationCaptureId}/frame1
outputBaseDir=${stitchBaseDir}/${stitchCaptureId}
frameInputDir=${framesDir}/${stitchCaptureId}/genUsable/usable

addCameraMeta2 "${frameInputDir}" 1 0
frameDirPrefix=frame
cpuOnly=0
while test ${currentFrame} -le ${endFrame}; do
  echo ${currentFrame}
  frameOutputDir=${outputBaseDir}/${frameDirPrefix}${currentFrame}

  mkdir -p ${frameOutputDir}

  cameraSfmPath=${frameOutputDir}/camera.sfm
  runCmd "aliceVision_cameraInit \
    --defaultCameraModel=${cameraModel} \
    --imageFolder ${frameInputDir}/${frameDirPrefix}${currentFrame} \
    --output=${cameraSfmPath} \
    --sensorDatabase=${sensorsDb} \
    --verboseLevel=${verboseLevel}"

  featuresPath=${frameOutputDir}/features
  mkdir -p ${featuresPath}
  runCmd "aliceVision_featureExtraction \
    --input=${cameraSfmPath} \
    --output=${featuresPath} \
    --forceCpuExtraction=${cpuOnly} \
    --describerTypes=${describerTypes} \
    --describerPreset=high \
    --verboseLevel=${verboseLevel}"

  imagePairsFile=${calibrationDir}/pairs.txt
  matchesPath=${frameOutputDir}/matches
  mkdir -p ${matchesPath}
  runCmd "aliceVision_featureMatching \
    --input=${cameraSfmPath} \
    --output=${matchesPath} \
    --featuresFolder=${featuresPath} \
    --describerTypes=${describerTypes} \
    --matchFilePerImage=1 \
    --imagePairsList=${imagePairsFile} \
    --verboseLevel=${verboseLevel}"

  calibrationSfmPath=${calibrationDir}/viewAndPoses.sfm
  stitchSfmPath=${frameOutputDir}/stitch.sfm 

  runCmd "aliceVision_computeStructureFromKnownPoses \
    --input=${calibrationSfmPath} \
    --output=${stitchSfmPath} \
    --featuresFolder=${featuresPath} \
    --matchesFolder=${matchesPath} \
    --describerTypes=${describerTypes} \
    --verboseLevel=${verboseLevel}"

  prepareDenseOutputDir=${frameOutputDir}/prepareDense
  srcImagesFolder=${frameInputDir}/${frameDirPrefix}${currentFrame}

  mkdir -p ${prepareDenseOutputDir}
  #sfmPath=${sfmBaseDir}/viewAndPoses.sfm
  runCmd "aliceVision_prepareDenseScene \
    --imagesFolders ${srcImagesFolder} \
    --input=${stitchSfmPath} \
    --outputFileType=jpg \
    --evCorrection=${correctEV} \
    --output=${prepareDenseOutputDir} \
    --verboseLevel=${verboseLevel}"

  estimateDepthOutputDir=${frameOutputDir}/estDepth
  mkdir -p ${estimateDepthOutputDir}
  runCmd "aliceVision_depthMapEstimation \
    --input=${stitchSfmPath} \
    --imagesFolder ${prepareDenseOutputDir} \
    --output=${estimateDepthOutputDir} \
    --downscale=1 \
    --verboseLevel=${verboseLevel}"

  filterDepthOutputDir=${frameOutputDir}/filterDepth
  mkdir -p ${filterDepthOutputDir}
  runCmd "aliceVision_depthMapFiltering \
    --input=${stitchSfmPath} \
    --depthMapsFolder ${estimateDepthOutputDir} \
    --output=${filterDepthOutputDir} \
    --verboseLevel=${verboseLevel}"

  meshFile=${frameOutputDir}/mesh.obj
  denseSfm=${frameOutputDir}/dense.sfm
  runCmd "aliceVision_meshing \
    --input=${stitchSfmPath} \
    --output=${denseSfm} \
    --outputMesh=${meshFile} \
    --depthMapsFolder ${estimateDepthOutputDir} \
    --depthMapsFilterFolder=${filterDepthOutputDir} \
    --colorizeOutput=1 \
    --verboseLevel=${verboseLevel}"

  filteredMeshFile=${frameOutputDir}/filteredMesh.obj
  runCmd "aliceVision_meshFiltering \
    --inputMesh=${meshFile} \
    --outputMesh=${filteredMeshFile} \
    --verboseLevel=${verboseLevel}"

  objOutputDir=${frameOutputDir}/objOutput
  runCmd "aliceVision_texturing \
    --input=${denseSfm} \
    --imagesFolder=${prepareDenseOutputDir} \
    --textureSide=16384 \
    --correctEV=${correctEV} \
    --output=${objOutputDir} \
    --inputMesh=${filteredMeshFile} \
    --fillHoles=0 \
    --verboseLevel=${verboseLevel}"

  currentFrame=$(expr ${currentFrame} + 1)
done
