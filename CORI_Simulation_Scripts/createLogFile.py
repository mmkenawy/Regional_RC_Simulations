import glob
import os

# create simulations log file from multiple files
logFile = open('simLog.txt','w')

filelist = glob.glob("logS*.txt")

for file in filelist:
  fileid = open(file,'r')
  logLines = fileid.read()
  logFile.write(logLines)
  fileid.close()
  os.remove(file)
  
logFile.close()



