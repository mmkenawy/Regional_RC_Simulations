% Driver for generating the response spectrum for multiple GMs
% user input
beta = 0.05; % damping ratio
% period range of interest
periods = [0.01:0.002:0.1,0.11:0.01:6.0];
g = 9.81; %m/s^2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(component,'FN') == 1
    Ind = 2;
elseif strcmp(component,'FP') == 1
    Ind = 3;
end

% import time history files
%%% file names
cd(GMset)
filenames=dir('*.data');

% number of GMs
numGMs = length(filenames);
spectra = struct;
GMs = struct;

for i = 1:numGMs
    fileID = fopen(filenames(i).name,'r');
    fgetl(fileID);
    GMfile = fscanf(fileID,'%f %f %f %f',[4 inf]);
    fclose(fileID);
    
    GMdata = GMfile';
    GMs(i).numPts = length(GMdata);
    GMs(i).time_step = GMdata(2,1) - GMdata(1,1);

    GMs(i).acc = GMdata(:,Ind); % acceleration is in m/s2
end
cd ../

SA_T1 = zeros(numGMs,1);
SV_T1 = zeros(numGMs,1);
figure;

for i = 1:numGMs
    npnts = GMs(i).numPts;
    delt = GMs(i).time_step;
    acc = GMs(i).acc;
    [sd,sv,sa] = spectrum(acc,npnts,delt,beta,periods);
    GMs(i).sd = sd;
    GMs(i).sv = sv;
    sa_g = sa/g;
    GMs(i).sa_g = sa_g;
    
%     loglog(periods,sa_g,'LineWidth',2,'Color','b')
%     hold on
    
    spectra(i).GM = filenames(i).name;
    spectra(i).sa_g = sa_g; % SA is saved in g units
    spectra(i).sv = sv; % SD is saved in m/s  
    spectra(i).sd = sd; % SV is saved in m
    
end
%legend({filenames.name},'Interpreter', 'none')

% xlabel('Periods (sec)')
% ylabel('Spectra Acceleration (g)')
% print ([GMset,component,'_SA_RS.pdf'],'-dpdf','-fillpage')

% plot the spectral velocity
% figure;
% for i = 1:numGMs
%     plot(periods,GMs(i).sv,'LineWidth',2)
%     hold on
% end
% legend({filenames.name},'Interpreter', 'none')

%save([GMset,component,'_SA_SV'],'periods','spectra')

%%%%%%%%%%%%%%%%%%%%% script to get the PGV of all GMs, while you are at it
%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PGV = zeros(numGMs,1);
for i = 1:numGMs
    acc = GMs(i).acc;
    npnts = GMs(i).numPts;
    delt = GMs(i).time_step;
    time_tot = (npnts - 1)*delt;
    time = 0:delt:time_tot;
    
%     figure;
%     plot(time,acc/g)
%     ylabel('Ground Acceleration (g)')

% integrate the acceleration and velocity records numerically
%     vel = zeros(npnts,1);
%     disp = zeros(npnts,1);
%     for i = 1:npnts-1
%     vel(i+1) = vel(i) + delt/2*(acc(i+1) + acc(i));
%     disp(i+1) = disp(i) + vel(i)*delt + delt^2*(acc(i+1)/6 + acc(i)/3);
%     end

    vel = cumsum(acc)'.*delt;
    PGV(i) = max(abs(vel));
    
    disp = cumsum(vel)'.*delt;

%     figure;
%     plot(time,vel)
%     ylabel('Ground velocity (m/s)')
%     hold on
%     plot(time,vel2)
%     figure;
%     plot(time,disp)
%     ylabel('Ground Displacement (m)')
%     hold on
%     plot(time,disp2)
end

save([GMset,component,'_SA_SV_PGV'],'periods','spectra','PGV')