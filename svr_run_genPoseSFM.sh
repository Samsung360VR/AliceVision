captureId=5d5a1f73-Cowboys3--AV
imageFilesBasePath=${HOME}/Work/Git/lens54/output
outputBasePath=`pwd`/output
dockerBin=nvidia-docker
mkdir -p ${outputBasePath}
echo ${imageFilesBasePath} 
echo ${outputBasePath} 
sudo ${dockerBin} stop alicevision_svr
sudo ${dockerBin} rm alicevision_svr
sudo ${dockerBin} pull volumetric-nas.local:5005/alicevision_svr:latest
sudo ${dockerBin} run --name alicevision_svr -d --rm \
  -v ${HOME}/Mnt/Bkp/data:/ext/input/nas-mount/data \
  -v ${imageFilesBasePath}:/ext/input/frames \
  -v ${outputBasePath}:/ext/output \
  -e CAPTURE_ID="${captureId}" \
  volumetric-nas.local:5005/alicevision_svr:latest \
  "/usr/src/app/scripts/genPoseSFM.sh"
