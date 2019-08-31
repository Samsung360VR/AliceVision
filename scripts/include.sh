addCameraMeta()
{
  camId=-1
  nasDataDir=${1}
  baseFramesDir=${2}
  captureId=${3}
  frameId=${4}
  imageType=jpeg
  imagesFolder=${baseFramesDir}/${captureId}/genUsable/usable/frame${frameId}
  ordersFile=${nasDataDir}/${captureId}/order.txt
  for serial in `cat ${ordersFile}`; do
    camId=$(expr 1 + ${camId})
    echo "Processing ${camId} - ${serial}"
    exiftool \
      -FocalLength="${FOCAL_LENGTH}" \
      -Make="${MAKE}" \
      -Model="${MODEL}" \
      -CameraSerialNumber="${serial}" \
      -SerialNumber="${serial}" \
      -LensSerialNumber="${serial}" \
      -overwrite_original_in_place \
      ${imagesFolder}/cam${camId}.${imageType}
  done
}
