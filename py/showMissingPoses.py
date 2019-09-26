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

def save(tgtSfm, oTgtSfm):
  if (tgtSfm is None):
    tgtSfm = "/dev/tty"
    
  result = dict()
  result["version"] = ["1", "0", "0"]
  result["featuresFolders"] = ["features"]
  result["matchesFolders"] = ["matches"]
  result["views"] = list(oTgtSfm["views"].values())
  result["intrinsics"] = list(oTgtSfm["intrinsics"].values())
  result["poses"] = list(oTgtSfm["poses"].values())

  with open(tgtSfm, "w") as fTgtSfm:
    json.dump(result, fTgtSfm, indent=2)

parser = argparse.ArgumentParser(description="Merge intrinsics, poses and views in AliceVision SFM")

parser.add_argument('--sfm', type=str, help="One or more source SFMs")
args = parser.parse_args()

returnCode = 1  
if (args.sfm is not None):
  try:
    with open(args.sfm, 'r') as fSfm:
      oSfm = json.load(fSfm)
  except Exception as ex:
    print(ex) 
    sys.exit(1)

poses = dict()

for pose in oSfm["poses"]:
  poseId = pose["poseId"]
  poses[poseId] = pose

for view in oSfm["views"]:
  viewId = view["viewId"]
  viewPoseId = view["poseId"]
  camSerial = view["metadata"]["Exif:BodySerialNumber"]
  if (viewPoseId not in poses):
    print(camSerial)

sys.exit(0)
