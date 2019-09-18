numCams=${NUM_CAMS}
frameId=${1}
imageType=jpeg
imagesFolder=/ext/input/frames/${CAPTURE_ID}/genUsable/usable/frame${frameId}
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
    -FocalLength="${FOCAL_LENGTH}" \
    -Make="${SVR_CAM_MAKE}" \
    -Model="${SVR_CAM_MODEL}" \
    -CameraSerialNumber="${camSerial}" \
    -SerialNumber="${camSerial}" \
    -LensSerialNumber="${lensSerial}" \
    -overwrite_original_in_place \
    ${imageFile}
  camId=$(expr 1 + ${camId})
done
