% Main driver for running multiple ground motion simulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User Input
buildingName = '12st'; %input the building name (same name on the building input files)
structPeriod = 2.23;
GMset = 'bakerpulse31'; % ground motion set
component = 'SN';
sim = 'E40'; % other simulation markers to be appended to output files
%%%%%%%%%%%%%%%%%%%%%%%%%% END USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analysisType = 'multipleGMs';
% First, call the Building Model Generator to read, process and create the
% tcl-based building simulation script
generateModel(buildingName,analysisType)

% set name of output directory
fileID = fopen('outputDir.tcl','w');
fprintf(fileID,['set dataDir "driftOutput_',buildingName,'_',GMset,component,sim,'"']);
fclose(fileID);

% RUN SIMULATIONS: go to Opensees and source multipleGMs.tcl
% EXTRACT OUTPUT: run output_multipleGMs.m

