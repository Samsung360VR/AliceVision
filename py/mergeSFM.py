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

parser.add_argument('--srcSfms', type=str, nargs='+', help="One or more source SFMs")
parser.add_argument('--srcSfmList', type=str, help="Text file containing paths to SFM files")
parser.add_argument("--tgtSfm", type=str, help="Target SFM file")
parser.add_argument("--numPoses", type=int, help="Expected number of poses in SFM")
args = parser.parse_args()

oTgtSfm = None
try:
  with open(args.tgtSfm, 'r') as fTgtSfm:
    oTgtSfm = json.load(fTgtSfm)
except Exception as ex:
  print(ex)
  oTgtSfm = None

returnCode = 1  
if (args.srcSfmList is not None):
  try:
    with open(args.srcSfmList, 'r') as fSfmList:
      for line in fSfmList:
        oTgtSfm = extract(oTgtSfm, line.strip())
        if (isComplete(oTgtSfm, args.numPoses)):
          returnCode = 0
          break;
  except:
      pass
elif (args.srcSfms is not None):
  for srcSfm in args.srcSfms:
    oTgtSfm = extract(oTgtSfm, srcSfm)
    if (isComplete(oTgtSfm, args.numPoses)):
      returnCode = 0
      break;

if oTgtSfm is not None:
  save(args.tgtSfm, oTgtSfm)

sys.exit(returnCode)