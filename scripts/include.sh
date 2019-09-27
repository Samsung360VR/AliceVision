addCameraMeta()
{
  nasDataDir=${1}
  baseFramesDir=${2}
  captureId=${3}
  frameId=${4}
  imageType=jpeg
  imagesFolder=${baseFramesDir}/${captureId}/genUsable/usable/frame${frameId}
  camId=0

  
  while true; do
    imageFile=${imagesFolder}/cam${camId}.${imageType}
    if test ! -f ${imageFile}; then
      echo "Done"
      break
    fi
    camSerial=C${camId}
    lensSerial=L${camId}
    echo ${imageFile} ${camId} ${camSerial} ${lensSerial}
    exiftool \
      -FocalLength="${SVR_CAM_FOCAL_LENGTH}" \
      -Make="${SVR_CAM_MAKE}" \
      -Model="${SVR_CAM_MODEL}" \
      -CameraSerialNumber="${camSerial}" \
      -SerialNumber="${camSerial}" \
      -LensSerialNumber="${lensSerial}" \
      -overwrite_original_in_place \
      ${imageFile}
    camId=$(expr 1 + ${camId})
  done
}


setupEnv()
{
  export calibrationBaseDir=/ext/output/aliceCalibration
  export stitchBaseDir=/ext/output/aliceStitch
  export sensorsDb=${AV_BUNDLE}/share/aliceVision/cameraSensors.db
  export describerTypes=sift,akaze
  export describerTypes=sift
  export numPoses=${NUM_CAMS}
  export verboseLevel=info
}

runCmd()
{
  cmd=${1}
  echo ${cmd}
  ${cmd}
}  

addCameraMeta2()
{
  baseDir=${1}
  startDirId=${2}
  startCamId=${3}
  imageType=jpeg
  camPrefix=cam
  dirPrefix=frame
  dirId=${startDirId}
  while true; do
    dirPath=${baseDir}/${dirPrefix}${dirId}
    if test ! -d ${dirPath}; then
      break
    fi
    echo ${dirPath}
    camId=${startCamId}
    while true; do
      camPath=${dirPath}/${camPrefix}${camId}.${imageType}
      if test ! -f ${camPath}; then
        break
      fi
      camSerial=C${camId}
      lensSerial=L${camId}
      imageId=I-${dirId}-${camId}
      echo ${camPath} ${camSerial} ${lensSerial} ${imageId}
      exiftool \
        -FocalLength="${SVR_CAM_FOCAL_LENGTH}" \
        -Make="${SVR_CAM_MAKE}" \
        -Model="${SVR_CAM_MODEL}" \
        -CameraSerialNumber="${camSerial}" \
        -SerialNumber="${camSerial}" \
        -LensSerialNumber="${lensSerial}" \
	-ImageUniqueID="${imageId}" \
        -overwrite_original_in_place \
        ${camPath}
      camId=$(expr 1 + ${camId})
    done
    dirId=$(expr 1 + ${dirId})
  done
}
