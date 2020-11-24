
# python script to create simulation files for multiple ground motions #
# By Maha Kenawy, UNR - Jan 29, 2020

import os
import pathlib
import user_input
import shutil

# Specify ground motion directory path
# option 1: specify directory in current directory

GMdir = '/GMfiles_' + user_input.GMset + user_input.component
mainpath = os.getcwd()
path = mainpath + GMdir

# # option 2: specify entire path
# path = 'C:/GMfiles_trial'

# delete old simulation files
for filename in os.listdir():
    if filename.startswith('GMS_'):
        os.unlink(filename)
        #print(filename)

# read the GM file names
files = os.listdir(path)
# reverse the path slashes for tcl!
tclpath = path.replace(os.sep,'/')

print(files)
nGM = len(files)
print(nGM)

# read the time incr
incrFile = open('timeincr.txt','r')
timeIncrList = incrFile.readlines()
incrFile.close()
#print(timeIncrList)

# read the number of steps
stepsFile = open('numPts.txt','r')
stepsList = stepsFile.readlines()
stepsFile.close()
#print(stepsList)

# ground motions scale factor
scalefact = 1.0

# create each file and write the GM information
for i in range(0,nGM):
	fileID = open('GM'+files[i]+'.tcl','w')
	L1 = 'set GMfile "'+tclpath+'/'+files[i]+'"\n'
	L2 = 'set GM "'+files[i]+'"\n'
	L3 = 'set DtEQ '+timeIncrList[i]
	L4 = 'set Nsteps '+stepsList[i]
	L5 = 'set scalefact '+str(scalefact)+'\n'
	L6 = 'source '+mainpath+'/runGM.tcl'
	
	fileID.writelines([L1,L2,L3,L4,L5,L6])
	fileID.close()

# create one file with the building name and output directory
dataDir = 'driftOutput_' + user_input.buildingName + '_' + user_input.GMset + user_input.component + user_input.sim
fileID2 = open('building_outputdir.tcl','w')
L10 = 'set buildingName '+ user_input.buildingName + '\n'
L11 = 'set dataDir ' + dataDir + '\n'
fileID2.writelines([L10,L11])
fileID2.close()

# delete old data dir and create a new one
shutil.rmtree(dataDir, ignore_errors=True)
os.mkdir(dataDir)

# save user input parameters for extracting results later by MATLAB
import scipy.io as sio
sio.savemat('user_input.mat',{'buildingName': user_input.buildingName,'GMset': user_input.GMset,'component': user_input.component,'sim': user_input.sim})

