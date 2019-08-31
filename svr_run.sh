captureId=5d5b1323p-Cowboys5
imageFilesBasePath=${HOME}/Work/Git/lens54/output
outputBasePath=`pwd`/output
mkdir -p ${outputBasePath}
echo ${imageFilesBasePath} 
echo ${outputBasePath} 
sudo nvidia-docker run \
  -it --rm \
  -v ${HOME}/Mnt/Bkp/data:/ext/nas-nfs-mount/data \
  -v ${imageFilesBasePath}:/ext/frames \
  -v ${outputBasePath}:/ext/output \
  -e CAPTURE_ID="${captureId}" \
  alicevision_svr:latest \
  /bin/bash
