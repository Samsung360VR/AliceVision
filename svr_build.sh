dockerBin=nvidia-docker
sudo ${dockerBin} pull volumetric-nas.local:5005/alicevision_base && \
sudo ${dockerBin} tag volumetric-nas.local:5005/alicevision_base alicevision_base && \
sudo ${dockerBin} build -t volumetric-nas.local:5005/alicevision_svr -f Dockerfile_ubuntu_svr . && \
sudo ${dockerBin} push volumetric-nas.local:5005/alicevision_svr && \
sudo ${dockerBin} tag volumetric-nas.local:5005/alicevision_svr alicevision_svr
