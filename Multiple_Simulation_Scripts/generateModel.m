% Building Input Control
function [] = generateModel(buildingName,analysisType)
% User Input
% buildingName = '6st';
% analysisType = 'multipleGMs'; % pushover, dynamic, freevib or multipleGMs
% saveSpecify = '';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Nstory,Nbay,Hcol1,Hcol2,Lbeam,tslab,useIMKCalibration,...
    PDeltaCol,colassign,beamassign,LL_perarea,DL_imp_perarea,RCdensity,g,inputunits]...
    = readBuildingInfo(buildingName);

save([buildingName,'_info'],'analysisType','PDeltaCol','Hcol1','Hcol2','Lbeam','inputunits')

% Nstory = 6;
% Nbay = 5;
% Hcol1 = 15*ft;
% Hcol2 = 12*ft;
% Lbeam = 30*ft;
% 
% tslab = 8*in; % minimum tslab = L/36;
% useIMKCalibration = 1;
% 
% % colassign = [1,2,3,6]; % story numbers where section assignment begins - 6st building
% % beamassign = colassign; % beam floor assignments - story numbers where
% % section assignments begin
% colassign = [1,2]; % story numbers where section assignment begins
% beamassign = [1];

%%%% how many frames does this frame laterally support? 
Nframes = 1; % not using this right now

Hbuilding = Hcol1 + (Nstory-1)*Hcol2;

colSecs = length(colassign);
beamSecs = length(beamassign);

% read and store column and beam section info as a .mat file each
colSectionInfo(buildingName,colSecs,useIMKCalibration,inputunits)
beamSectionInfo(buildingName,beamSecs,useIMKCalibration,inputunits)

% create a structure with all frame loading info
[storyinfo,Wbuilding] = frameInfo(buildingName,Nstory,Nbay,Hcol1,Hcol2,Lbeam,...
    colassign,beamassign,tslab,Nframes,useIMKCalibration,LL_perarea,DL_imp_perarea,RCdensity,g);

writeFrameInfo(buildingName,Nstory,Nbay,Hcol1,Hcol2,Lbeam,storyinfo,PDeltaCol,analysisType,g,inputunits)

% calibrate the parameters of each member and write the parameters to a
% .tcl file
memParameters(storyinfo,Lbeam,useIMKCalibration,Nbay,inputunits)
end