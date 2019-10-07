import os, argparse, json, sys, copy

def getValue(di, a, d):
  if (a in di):
    return di[a]
  return d

def map1(oTgtSfm, key, read):
  avail = getValue(oTgtSfm, key, dict())
  for key2 in read.keys():
    if (key2 in avail):
      continue
    rk2 = read[key2]
    avail[key2] = rk2
  oTgtSfm[key] = avail
  return oTgtSfm

def extract(oTgtSfm, srcSfm):
  print("Processing %s" % (srcSfm))
  try:
    with open(srcSfm, 'r') as fSrcSfm:
      oSrcSfm = json.load(fSrcSfm)
  except:
    oSrcSfm = None
  if (oTgtSfm is None):
    oTgtSfm = dict()

  if (oSrcSfm is not None):

    myViews = dict()
    for view in oSrcSfm["views"]:
      key = view["viewId"]
      myViews[key] = view

    myIntrinsics = dict()
    for intrinsic in oSrcSfm["intrinsics"]:
      key = intrinsic["intrinsicId"]
      myIntrinsics[key] = intrinsic

    myPoses = dict()
    for pose in oSrcSfm["poses"]:
      key = pose["poseId"]
      myPoses[key] = pose

    oTgtSfm = map1(oTgtSfm, "views", myViews)
    oTgtSfm = map1(oTgtSfm, "intrinsics", myIntrinsics)
    oTgtSfm = map1(oTgtSfm, "poses", myPoses)

  return oTgtSfm

def isComplete(oTgtSfm, numPoses):
  if (numPoses is None):
    numPoses = len(oTgtSfm["views"].values())
  return numPoses <= len(oTgtSfm["poses"].values())

def load(sfmFile):
  if (sfmFile is None):
    return None
  try:
    with open(sfmFile, 'r') as fSfm:
      return json.load(fSfm)
  except Exception as ex:
    print(ex) 
  return None

def save(tgtSfm, oTgtSfm):
  if (tgtSfm is None):
    tgtSfm = "/dev/tty"

  with open(tgtSfm, "w") as fTgtSfm:
    json.dump(oTgtSfm, fTgtSfm, indent=2)

def getKeyForCamLens(metadata):
  camSerial = metadata["Exif:BodySerialNumber"]
  lensSerial = metadata["Exif:LensSerialNumber"]
  return camSerial + "_" + lensSerial

parser = argparse.ArgumentParser(description="Merge intrinsics, poses and views in AliceVision SFM")

parser.add_argument('--posesSfm', type=str, help="SFM with poses")
parser.add_argument('--viewsSfm', type=str, help="SFM with views")
parser.add_argument("--tgtSfm", type=str, help="Target SFM file")
args = parser.parse_args()

posesSfm = load(args.posesSfm)
if (posesSfm is None):
  sys.exit(1)
posesMap = dict()
posesSfmPoses = posesSfm["poses"]
for posesSfmPose in posesSfmPoses:
  poseId = posesSfmPose["poseId"]
  posesMap[poseId] = posesSfmPose
posesSfmViews = posesSfm["views"]
posesBridge = dict()
for posesSfmView in posesSfmViews:
  poseId = posesSfmView["poseId"]
  if (poseId not in posesMap):
    print("PoseId " + poseId + " not found !")
  else:
    pose = posesMap[poseId]
    metadata = posesSfmView["metadata"]
    key = getKeyForCamLens(metadata)
    posesBridge[key] = pose

viewsSfm = load(args.viewsSfm)
if (viewsSfm is None):
  sys.exit(1)

viewsSfm["poses"] = list(posesBridge.values())
viewSfmViews = viewsSfm["views"]  
for viewSfmView in viewSfmViews:
  metadata = viewSfmView["metadata"]
  key = getKeyForCamLens(metadata)
  if (key not in posesBridge):
    print("Key " + key + " not found in poses")
    sys.exit(1)
  pose = posesBridge[key]
  viewSfmView["poseId"] = pose["poseId"]

save(args.tgtSfm, viewsSfm)
sys.exit(0)
