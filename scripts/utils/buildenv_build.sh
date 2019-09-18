git submodule update -i
sudo docker build -t volumetric-nas.local:5005/alicevision_buildenv -f Dockerfile_ubuntu_buildenv .
sudo docker push volumetric-nas.local:5005/alicevision_buildenv
