fullPath=$(realpath "$0")
scriptDir=$(dirname "$fullPath")
. ${scriptDir}/env.sh
basePath=$(pwd)
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
  -e AV_DEV=${AV_DEV} \
  -e AV_BUILD=${AV_BUILD} \
  -e AV_INSTALL=${AV_INSTALL} \
  -e AV_BUNDLE=${AV_BUNDLE} \
  volumetric-nas.local:5005/alicevision_buildenv:latest \
  "/bin/bash"
