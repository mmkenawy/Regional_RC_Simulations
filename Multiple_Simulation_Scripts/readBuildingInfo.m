function [Nstory,Nbay,Hcol1,Hcol2,Lbeam,tslab,useIMKCalibration,...
    PDeltaCol,colassign,beamassign,LL_perarea,DL_imp_perarea,RCdensity,g,inputunits]...
    = readBuildingInfo(buildingName)

% building info are assumed to be in kips,inchs (and feet)
[data,~,raw] = xlsread([buildingName,'_info'],'C1:C15');

Nstory = data(1);
Nbay = data(2);
Hcol1 = data(3);
Hcol2 = data(4);
Lbeam = data(5);
tslab = data(6);
useIMKCalibration = data(7);
PDeltaCol = data(8);
colassign = cell2mat(raw(9,1));
beamassign = cell2mat(raw(10,1));
tfc = ischar(colassign);
tfb = ischar(beamassign);
if tfc == 1
    colassign = str2num(colassign); %#ok<*ST2NM>
end

if tfb == 1
    beamassign = str2num(beamassign);
end
DL_imp_perarea = data(11);
LL_perarea = data(12);
RCdensity = data(13);
g = data(14);
inputunits = data(15);
end