
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MAIN SCRIPT TO EXTRACT AND PLOT OUTPUT OF LARGE REGIONAL SIMULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USER INPUT: DEFINE BUILDING AND SIMULATION SET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
buildingName = '12st';
T1 = 2.23; %12 story
%T1 = 0.75; % 3 story
GMset = 'g23subset';
component = 'FN';
sim = 'E40';
saveSpecify = [buildingName,'_',GMset,component,sim];
% choose subset for creating plots (optional)
GMsubset = ''; % options: '', 'near' or 'far'
% near GMs are within 10 km of fault
% far GMs are beyond 10 km from fault

% Two options here:
% option 1: extract the drift output of a new simulation (set newSim = 1)
% option 2: plot existing output of an old simulation (set newSim = 0)
newSim = 1; % 1 or 0

% SET THE GROUND MOTION STATIONS GRID BASED ON THE NUMBER OF GMS
Xstations = 2;
Ystations = 1;
eqsource = [28.5,10]; % the coordinates of the earthquake fault rupture source

% PLOT DRIFT ENVELOPES AT SELECT STATIONS
% assign the indices of ground motions you want to plot the drift envelope for
%plot_ind = [1007,1071]; % CAN ASSIGN ANY OTHER SET OF INDICES
plot_ind = [1,2]; % CAN ASSIGN ANY OTHER SET OF INDICES

%%%%%%%%%%%%%%%%%%%%%%%%%% END USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD OR EXTRACT OUTPUT DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analysisType = 'multipleGMs';
load([buildingName,'_info'],'Wbuilding','Hbuilding','Nstory','Nbay')

if newSim == 1 % option 1
    [BDrifts,IDrifts] = extractMaxDrift(saveSpecify);
elseif newSim == 0 % option 2
    load(['maxDrifts_',saveSpecify],'BDrifts','IDrifts');
end

% GET SPECTRA AND PULSE CLASSIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if ground motion IMs exist - create them if they don't
if isfile([GMset,component,'_SA_SV_PGV.mat'])
else
    specDriver
end

% load the PGV
load([GMset,component,'_SA_SV_PGV'],'PGV')

% generate an array of SA(T1) and SV(T1) for this building
[SA_T1,SV_T1] = spectra_T1(T1,GMset,component);

% check if ground motion pulse classification exists - create it if it
% doesn't
if isfile([GMset,'_pulse_class.mat'])
else
    classify_record_main
end
load([GMset,'_pulse_class'],'pulse_class','Tpulse');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROCESS THE DRIFT OUTPUT DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nGMs = length(BDrifts);
maxBDrift = zeros(nGMs,1);
maxIDrifts = zeros(Nstory,nGMs);

for i = 1:nGMs
    maxBDrift(i) = BDrifts(i).value;
    story = 0;
    for j = ((i - 1)*Nstory) + 1 : i*Nstory
        story = story +1;
        maxIDrifts(story,i) = IDrifts(j).value;
    end
end

% extract maximum interstory drift for each run
maxIDrift_GM = zeros(1,nGMs);
for i = 1:nGMs
    maxIDrift_GM(i) = max(maxIDrifts(:,i));
end

% % extract max drift per story
% maxIDrift_story = zeros(Nstory,1);
% for j = 1:Nstory
%     maxIDrift_story(j) = max(maxIDrifts(j,:));
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if the plots are specialized for a certain subset, do some replacements
real_FNdistance = abs(eqsource(2) - [BDrifts.FNdistance]);

if strcmp(GMsubset,'') ~= 1
    if strcmp(GMsubset,'near') == 1
        GMsubset_ind = find(real_FNdistance < 10);
    elseif strcmp(GMsubset,'far') == 1
        GMsubset_ind = find(real_FNdistance > 10);
    end
    nGMsubset = length(GMsubset_ind);

    % to replace plots, overwrite the following
    nGMs = nGMsubset;
    maxIDrift_GM = maxIDrift_GM(GMsubset_ind);
    maxBDrift = maxBDrift(GMsubset_ind);
    Ystations = nGMsubset/Xstations;
    BDrifts = BDrifts(GMsubset_ind(1):GMsubset_ind(end));
    pulse_class = pulse_class(GMsubset_ind);
    Tpulse = Tpulse(GMsubset_ind);
    SA_T1 = SA_T1(GMsubset_ind);
    SV_T1 = SV_T1(GMsubset_ind);
    PGV = PGV(GMsubset_ind);
    saveSpecify = [saveSpecify,GMsubset];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT DRIFTS VS DISTANCES FROM FAULT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot_drift_envelope_vs_distance([BDrifts.FPdistance],[BDrifts.FNdistance],maxBDrift,maxIDrift_GM,...
    Xstations,Ystations,buildingName,saveSpecify)

colorLabelFP = 'Distance Parallel to Fault (km)';
[plotLimFP,tickLocsFP,tickLabelsFP] = bar_ticks([BDrifts.FPdistance]);
plot_drift_vs_distance_color([BDrifts.FNdistance],xaxisLabelFN,maxBDrift,maxIDrift_GM,...
    [BDrifts.FPdistance],'default',colorLabelFP,plotLimFP,tickLocsFP,tickLabelsFP,...
    buildingName,saveSpecify,'Ndist')

colorLabelFN = 'Distance Normal to Fault(km)';
[plotLimFN,tickLocsFN,tickLabelsFN] = bar_ticks([BDrifts.FNdistance]);
plot_drift_vs_distance_color([BDrifts.FPdistance],xaxisLabelFP,maxBDrift,maxIDrift_GM,...
    [BDrifts.FNdistance],'default',colorLabelFN,plotLimFN,tickLocsFN,tickLabelsFN,...
    buildingName,saveSpecify,'Pdist')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT THE RISK MAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %call the function that plots the hazard map
[haz_colormap,haz_levels] = hazMap([BDrifts.FPdistance],[BDrifts.FNdistance],maxIDrift_GM,...
    buildingName,saveSpecify,eqsource,Xstations,Ystations);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT DRIFTS VS INTENSITY MEASURES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colorLabelFP = 'Fault Normal Distance (km)';
map = 'default';
plot_drift_IMs([BDrifts.FNdistance],maxBDrift,maxIDrift_GM,...
    SA_T1,SV_T1,PGV,buildingName,saveSpecify,map,colorLabelFP)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT DRIFT ENVELOPES FOR SELECTED GROUND MOTION INDICES
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find pulse GMs with large Tp (can replace plot_ind in the function)
smallpulse_ind = find(Tpulse/T1 > 0.1 & Tpulse/T1 < 0.5);
midpulse_ind = find(Tpulse/T1 > 0.5 & Tpulse/T1 < 1.0);
largepulse_ind = find(Tpulse/T1 > 1.0 & Tpulse/T1 < 2.0);
verylargepulse_ind = find(Tpulse/T1 > 2);

plot_drift_envelopes(plot_ind,Nstory,maxIDrifts,BDrifts,saveSpecify)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT PULSE CHARACTERISTICS VS DRIFTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PULSE GROUND MOTIONS MAP
[pulseColorMap,pulse_levels,plotLim_Tp,ticklabels_Tp] = generic_map([BDrifts.FPdistance],...
    [BDrifts.FNdistance],Tpulse/T1,buildingName,saveSpecify,eqsource,Xstations,Ystations);

% plot dirft vs normal distance with Tp color coding
colorLabelpulse = 'Normalized Pulse Period T_p/T_1';
plot_drift_vs_distance_color([BDrifts.FNdistance],xaxisLabelFN,maxBDrift,maxIDrift_GM,...
    Tpulse/T1,pulseColorMap,colorLabelpulse,plotLim_Tp,pulse_levels,ticklabels_Tp,...
    buildingName,saveSpecify,'Ndist_pulse')

% plot dirft vs parallel distance with Tp color coding
plot_drift_vs_distance_color([BDrifts.FPdistance],xaxisLabelFP,maxBDrift,maxIDrift_GM,...
    Tpulse/T1,pulseColorMap,colorLabelpulse,plotLim_Tp,pulse_levels,ticklabels_Tp,...
    buildingName,saveSpecify,'Pdist_pulse')

% plot dirft vs ground motion IMs with Tp color coding
plot_drift_IMs(Tpulse/T1,maxBDrift,maxIDrift_GM,...
    SA_T1,SV_T1,PGV,buildingName,saveSpecify,pulseColorMap,colorLabelpulse)
