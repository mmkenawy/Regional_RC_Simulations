% Script for preparing the GM files
%%% convert to .txt files
%%% extract time increment of each GM
%%% extract number of steps of each GM
GMset = 'basinAsubset2'; % NAME OF THE DIR CONTAINING THE GROUND MOTION .DATA FILES 
% (WHICH IS IN THE SAME DIRECTORY AS THIS SCRIPT)
component = 'FN'; % FN or FP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

currPath = pwd;
% fault normal or parallel
if strcmp(component,'FN') == 1
    Ind = 2;
elseif strcmp(component,'FP') == 1
    Ind = 3;
end

% import time history files
%%% file names
cd([currPath,'/',GMset])
filenames=dir('*.data');

% number of GMs
numGMs = length(filenames);

numPts = zeros(numGMs,1);
time_step = zeros(numGMs,1);

% loop over files to generate needed parameters and rewrite text files
status1 = rmdir([currPath,'/GMfiles_',GMset,component],'s');
mkdir([currPath,'/GMfiles_',GMset,component])

for i = 1:numGMs
% get number of data points
    file_in = fopen(filenames(i).name, 'r');
    fgetl(file_in);
    GMfile = fscanf(file_in,'%f',[4 inf]);
    fclose(file_in);
    
    GMdata = GMfile';
    numPts(i) = length(GMdata);
    [~,name,ext] = fileparts(filenames(i).name);
    filename = name;

    % get time step
    time = GMdata(:,1);
    time_step(i) = time(2) - time(1);

    %conv = 0.0254; % convert m/s2 to in/s2
    conv = 9.81; % normalize to g units
    accNorm = GMdata(:,Ind)./conv;

%     plot(time,accNorm,'LineWidth',2);
%     hold on

    % write data to text files
    %%% gm acceletration time history
    % write data to textfiles in a subdirectory in the same directory
    fileID = fopen([currPath,'/GMfiles_',GMset,component,'/',filename,'.txt'],'w');
    fprintf(fileID,'%2.12e \n',accNorm);
    fclose(fileID);

%     % write data to textfiles in a subdirectory under C (mkdir first)
%     fileID2 = fopen(['C:/GMfiles_',GMset,component,'/',filename,'.txt'],'w');
%     fprintf(fileID2,'%2.12e \n',accNorm);
%     fclose(fileID2);
end
cd ..

% write time increments file
%%% time increments
fileIDtime = fopen([currPath,'/timeincr.txt'],'w');
fprintf(fileIDtime,'%2.5f \n',time_step);
fclose(fileIDtime);

%%% write number of data points file
fileIDpts = fopen([currPath,'/numPts.txt'],'w');
fprintf(fileIDpts,'%d \n',numPts);
fclose(fileIDpts);

% write file with path to ground motion acc time series (for opensees
% simulations)
fileID3 = fopen([currPath,'/pathToGMs.tcl'],'w');
currPathtcl = strrep(currPath,'\','/');
fprintf(fileID3,['set GMdir "',currPathtcl,'/GMfiles_',GMset,component,'"']);
fclose(fileID3);