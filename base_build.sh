git submodule update -i
sudo docker build -t volumetric-nas.local:5005/alicevision_base -f Dockerfile_ubuntu_base .
sudo docker push volumetric-nas.local:5005/alicevision_base
