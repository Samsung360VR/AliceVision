dockerBasePath=$(pwd)/../docker
dockerBasePath=$(realpath ${dockerBasePath})
buildPath=${dockerBasePath}/build
installPath=${dockerBasePath}/install
bundlePath=${dockerBasePath}/bundle
mkdir -p ${buildPath} ${installPath} ${bundlePath}
dockerBin=nvidia-docker
sudo ${dockerBin} stop alicevision_base
sudo ${dockerBin} rm alicevision_base
sudo ${dockerBin} pull volumetric-nas.local:5005/alicevision_base
sudo ${dockerBin} run --name alicevision_base -it --rm \
  -v ${buildPath}:/opt/AliceVision/build \
  -v ${installPath}:/opt/AliceVision/install \
  -v ${bundlePath}:/opt/AliceVision/bundle \
  volumetric-nas.local:5005/alicevision_base:latest \
  "/bin/bash"
