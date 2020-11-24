%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parser for DOE GM files
% ---------------------------------
% Input : filename and ground motion component (FN or FP)
% 
% Outputs: 
%   -Acceleration time history (Acc)
%   -Time step used for recording (record_dt)        
%   -Number of recorded points (NPTS)
%   -error code to indicate if the file was not present (errCode)
%       --errCode = 0 if successful, -1 if File not found
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [accNorm,record_dt,NPTS,errCode] = parseDATA_mk(filename,component)
file_in = fopen(filename, 'r');
if(file_in == -1)
    accNorm = -1;
    record_dt = -1;
    errCode = -1;
    NPTS = -1;
else
    if strcmp(component,'FN') == 1
        Ind = 2;
    elseif strcmp(component,'FP') == 1
        Ind = 3;
    end
        
    % get number of data points
    fgetl(file_in);
    GMfile = fscanf(file_in,'%f %f %f %f',[4 inf]);
    GMdata = GMfile';
    NPTS = length(GMdata);
    [~,name,ext] = fileparts(filename);
    filename = name;

    % get time step
    time = GMdata(:,1);
    record_dt = time(2) - time(1);

    conv = 9.81; % normalize to g units (the file contains acc in m/s2)
    accNorm = GMdata(:,Ind)./conv;

    %plot(time,accNorm,'LineWidth',2);
    fclose(file_in);
    errCode = 0;
end