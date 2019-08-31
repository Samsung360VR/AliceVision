captureId=5d5a1f73-Cowboys3--AV
imageFilesBasePath=${HOME}/AliceVision/Frames
outputBasePath=`pwd`/output
dockerBin=docker
mkdir -p ${outputBasePath}
echo ${imageFilesBasePath} 
echo ${outputBasePath} 
sudo ${dockerBin} run -d --rm \
  -v ${HOME}/Mnt/Bkp/data:/ext/input/nas-mount/data \
  -v ${imageFilesBasePath}:/ext/input/frames \
  -v ${outputBasePath}:/ext/output \
  -e CAPTURE_ID="${captureId}" \
  alicevision_svr:latest \
  "/scripts/genPoseSFM.sh"
