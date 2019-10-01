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
  #export describerTypes=sift,akaze
  export describerTypes=sift
  export cameraModel=pinhole
  export numPoses=${NUM_CAMS}
  export correctEV=0
  export verboseLevel=info
}

runCmd()
{
  cmd=${1}
  echo ${cmd}
  if test -z ${DRY_RUN}; then
    ${cmd}
  fi
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
    cmdBase="exiftool \
        -FocalLength=\"${SVR_CAM_FOCAL_LENGTH}\" \
        -Make=\"${SVR_CAM_MAKE}\" \
        -Model=\"${SVR_CAM_MODEL}\" \
        -overwrite_original_in_place"
    cmdFile=${dirPath}/cmd.txt
    processed=0
    if test -f ${cmdFile}; then
      contents=$(cat ${cmdFile})
      a=$(echo ${contents} | sed -e "s/\"//g")
      b=$(echo ${cmdBase} | sed -e "s/\"//g")
      if test "${a}" = "${b}"; then
        echo "PROCESSED"
        processed=1
      else
        rm -f ${cmdFile}
      fi
    fi
    if test ${processed} -eq 0; then
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
	fullCmd="${cmdBase} \
          -CameraSerialNumber=\"${camSerial}\" \
          -SerialNumber=\"${camSerial}\" \
          -LensSerialNumber=\"${lensSerial}\" \
	  -ImageUniqueID=\"${imageId}\" \
          ${camPath}"
	echo ${fullCmd}
	eval ${fullCmd}
        camId=$(expr 1 + ${camId})
      done
      echo ${cmdBase} > ${cmdFile}
    fi
    dirId=$(expr 1 + ${dirId})
  done
}
