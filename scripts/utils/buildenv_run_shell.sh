fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")
. ${scriptDir}/env.sh
basePath=$(pwd)
captureId=5d5a1f73-Cowboys3--AV
nasDataDir=${HOME}/Mnt/Bkp/data
imageFilesBasePath=${HOME}/Work/Git/lens54/output
stitchOutPath=${basePath}/../output
stitchOutPath=$(realpath ${stitchOutPath})
outBasePath=${basePath}/out
buildPath=${outBasePath}/build
installPath=${outBasePath}/install
bundlePath=${outBasePath}/bundle
sudo mkdir -p ${buildPath} ${installPath} ${bundlePath}
dockerBin=nvidia-docker
sudo ${dockerBin} stop alicevision_buildenv
sudo ${dockerBin} rm alicevision_buildenv
sudo ${dockerBin} pull volumetric-nas.local:5005/alicevision_buildenv
sudo ${dockerBin} run --name alicevision_buildenv -it --rm \
  -v ${buildPath}:${AV_BUILD} \
  -v ${installPath}:${AV_INSTALL} \
  -v ${bundlePath}:${AV_BUNDLE} \
  -v ${basePath}:${AV_DEV} \
  -v ${imageFilesBasePath}:/ext/input/frames \
  -v ${stitchOutPath}:/ext/output \
  -v ${nasDataDir}:/ext/input/nas-mount/data \
  -e AV_DEV=${AV_DEV} \
  -e AV_BUILD=${AV_BUILD} \
  -e AV_INSTALL=${AV_INSTALL} \
  -e AV_BUNDLE=${AV_BUNDLE} \
  -e CAPTURE_ID="${captureId}" \
  volumetric-nas.local:5005/alicevision_buildenv:latest \
  "/bin/bash"
