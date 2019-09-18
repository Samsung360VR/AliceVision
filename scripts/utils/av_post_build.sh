if test ! -f ${AV_DEV}/vlfeat_K80L3.SIFT.tree; then
  cd ${AV_DEV}
  echo "Downloading vlfeat_K80L3.SIFT.tree"
  wget https://gitlab.com/alicevision/trainedVocabularyTreeData/raw/master/vlfeat_K80L3.SIFT.tree
fi
cp -R ${AV_DEV}/vlfeat_K80L3.SIFT.tree ${AV_BUNDLE}/share/aliceVision
echo "${SVR_CAM_MAKE};${SVR_CAM_MODEL};${SVR_CAM_FOCAL_LENGTH}" >> ${AV_BUNDLE}/share/aliceVision/cameraSensors.db
