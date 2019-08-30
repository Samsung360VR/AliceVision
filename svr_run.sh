captureId=5d5b0c82-Cowboys5--AV
imageFilesBasePath=${HOME}/Work/Git/lens54/tools/output
sudo docker build -t alicevision -f Dockerfile_ubuntu_run .
sudo docker run \
  -it --rm \
  -v ${HOME}/Mnt/Bkp/data:/ext/nas-nfs-mount/data \
  -v ${imageFilesBasePath}:/ext/frames \
  -e CAPTURE_ID="${captureId}" \
  alicevision:latest \
  /bin/bash
