#!/bin/sh

fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")

. ${scriptDir}/include.sh
setupEnv

stitchCaptureId=${CAPTURE_ID}
calibrationCaptureId=${CAPTURE_ID}
startFrame=1
endFrame=1
framesDir=/ext/input/frames
outputBaseDir=${stitchBaseDir}/${stitchCaptureId}
sfmBaseDir=${calibrationBaseDir}/${calibrationCaptureId}/frame1
currentFrame=${startFrame}

frameInputDir=${framesDir}/${stitchCaptureId}/genUsable/usable
addCameraMeta2 "${frameInputDir}" 1 0
frameDirPrefix=frame
while test ${currentFrame} -le ${endFrame}; do
  echo ${currentFrame}
  frameOutputDir=${outputBaseDir}/${frameDirPrefix}${currentFrame}
  prepareDenseOutputDir=${frameOutputDir}/prepareDense
  mkdir -p ${prepareDenseOutputDir}
  sfmPath=${sfmBaseDir}/incremental.sfm
  runCmd "aliceVision_prepareDenseScene \
    --imagesFolders ${frameInputDir}/${frameDirPrefix}${currentFrame} \
    --input=${sfmPath} \
    --outputFileType=png \
    --evCorrection=1 \
    --output=${prepareDenseOutputDir} \
    --verboseLevel=${verboseLevel}"
  estimateDepthOutputDir=${frameOutputDir}/estDepth
  mkdir -p ${estimateDepthOutputDir}
  runCmd "aliceVision_depthMapEstimation \
    --input=${sfmPath} \
    --imagesFolder ${prepareDenseOutputDir} \
    --output=${estimateDepthOutputDir} \
    --downscale=1 \
    --verboseLevel=${verboseLevel}"
  filterDepthOutputDir=${frameOutputDir}/filterDepth
  mkdir -p ${filterDepthOutputDir}
  runCmd "aliceVision_depthMapFiltering \
    --input=${sfmPath} \
    --depthMapsFolder ${estimateDepthOutputDir} \
    --output=${filterDepthOutputDir} \
    --verboseLevel=${verboseLevel}"
  meshFile=${frameOutputDir}/mesh.obj
  denseSfm=${frameOutputDir}/dense.sfm
  runCmd "aliceVision_meshing \
    --input=${sfmPath} \
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
    --textureSide=16384 \
    --correctEV=1 \
    --output=${objOutputDir} \
    --inputMesh=${filteredMeshFile} \
    --fillHoles=1 \
    --verboseLevel=${verboseLevel}"
  currentFrame=$(expr ${currentFrame} + 1)
done
