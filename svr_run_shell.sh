dockerBasePath=$(pwd)/../docker
dockerBasePath=$(realpath ${dockerBasePath})
buildPath=${dockerBasePath}/build
installPath=${dockerBasePath}/install
bundlePath=${dockerBasePath}/bundle
outputPath=${dockerBasePath}/output
dockerBin=nvidia-docker
captureId=5d5a1f73-Cowboys3--AV
imageFilesBasePath=${HOME}/AliceVision/Frames

mkdir -p ${buildPath} ${installPath} ${bundlePath} ${outputPath}
sudo ${dockerBin} stop alicevision_svr
sudo ${dockerBin} rm alicevision_svr
sudo ${dockerBin} pull volumetric-nas.local:5005/alicevision_svr 
sudo ${dockerBin} run --name alicevision_svr -it --rm \
  -v ${buildPath}:/opt/AliceVision/build \
  -v ${installPath}:/opt/AliceVision/install \
  -v ${bundlePath}:/opt/AliceVision/bundle \
  -v ${HOME}/Mnt/Bkp/data:/ext/input/nas-mount/data \
  -v ${imageFilesBasePath}:/ext/input/frames \
  -v ${outputPath}:/ext/output \
  -e CAPTURE_ID="${captureId}" \
  volumetric-nas.local:5005/alicevision_svr:latest \
  "/bin/bash"
