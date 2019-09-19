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
