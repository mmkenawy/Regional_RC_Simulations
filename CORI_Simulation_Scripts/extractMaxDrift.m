function [] = extractMaxDrift(saveSpecify)
% extract and save drift output
drift_dir = ['driftOutput_',saveSpecify];
cd(drift_dir)

% % create a structure for the new data
peakdriftfiles = dir('DrNode*.out');
IDfiles = dir('DriftFloor*.out');
fields = {'date','bytes','isdir','datenum'};
BDrifts = rmfield(peakdriftfiles,fields);
IDrifts = rmfield(IDfiles,fields);

for i = 1:length(BDrifts)
fileID = fopen(BDrifts(i).name,'r');
BDrifts(i).value = max(abs(fscanf(fileID,'%f',[1 Inf])'));
%BDrifts(i).value = BDrifts(i).value(1,2);
%BDrifts(i).name = regexprep({BDrifts(i).name},'.txt.out','');
%BDrifts(i).name = regexprep(BDrifts(i).name,'DrNode1.00','');
fclose(fileID);
end

for i = 1:length(IDrifts)
fileID = fopen(IDrifts(i).name,'r');
IDrifts(i).value = max(abs(fscanf(fileID,'%f',[1 Inf])'));
%IDrifts(i).value = IDrifts(i).value(1,2);
%IDrifts(i).name = regexprep({IDrifts(i).name}, '.out','');
fclose(fileID);
end

% find fault distance for each ground motion
for i = 1:length(BDrifts)
    strTmp = char(BDrifts(i).name);
    %BDrifts(i).FNdistance = str2double(strTmp(7:8)) - eqsource(2);
    %BDrifts(i).FPdistance = str2double(strTmp(10:11)) - eqsource(1);
    BDrifts(i).FNdistance = str2double(strTmp(13:14));
    BDrifts(i).FPdistance = str2double(strTmp(16:17));
end

cd ../
save(['maxDrifts_',saveSpecify],'BDrifts','IDrifts');
end