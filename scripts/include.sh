function addCameraMeta {
  camId=-1
  captureId=${1}
  frameId=${2}
  imageType=jpeg
  imagesFolder=/ext/frames/${captureId}/genUsable/usable/frame${frameId}
  ordersFile=/ext/nas-nfs-mount/data/${captureId}/order.txt
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
