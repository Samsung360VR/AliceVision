camId=-1
frameId=${1}
imageType=jpeg
imagesFolder=/ext/frames/${CAPTURE_ID}/genUsable/usable/frame${frameId}
ordersFile=/ext/nas-nfs-mount/data/${CAPTURE_ID}/order.txt
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
