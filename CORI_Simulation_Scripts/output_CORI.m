%%%%%%%%% MAIN POSTPROCESSING SCRIPT TO EXTRACT ALL OUTPUT DRIFTS %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load the simulation specific tags (buildingName, GMset, component, sim):
    % if saving the user-input data in .mat file (using python scipy package in creatSimFiles.py)
    load('user_input.mat')
    saveSpecify = [buildingName,'_',GMset,component,sim];

    % % Otherwise, use the building_outputdir.tcl file
    % fileID = fopen('building_outputdir.tcl','r');
    % fgetl(fileID);
    % outputDir = fscanf(fileID,'%s');
    % saveSpecify = outputDir(23:end);

% run the function that extracts all drifts:
    extractMaxDrift(saveSpecify);