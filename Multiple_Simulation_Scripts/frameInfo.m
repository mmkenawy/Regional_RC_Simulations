function [storyinfo,Wbuilding] = frameInfo(buildingName,Nstory,Nbay,Hcol1,Hcol2,Lbeam,...
     colassign,beamassign,tslab,Nframes,useIMKCalibration,LL_perarea,DL_imp_perarea,RCdensity,g)

% %%%% how many frames does this frame laterally support? 
% Nframes = 1;

% section dimensions
% number of column sections
colSecs = length(colassign);
% number of beam sections
beamSecs = length(beamassign);

% create a data structure for floor data
storyinfo = struct;
storyinfo(1).Hcol = Hcol1;
for i = 2:Nstory
storyinfo(i).Hcol = Hcol2;
end

Ncol = Nbay + 1; %number of columns in a story

% get column dimensions
colNames = strings(Nstory,1);
colArea = zeros(Nstory,1);

for k = 1:colSecs - 1
    % assign column section names and dimensions to the right floors
    for i = colassign(k):colassign(k+1) - 1
        colNames(i) = [buildingName,'_C',num2str(k)];
        if useIMKCalibration == 1
            load(colNames(i),'b','h');
            colArea(i) = b*h;
        else
            load(colNames(i),'A_ele')
            colArea(i) = A_ele;
        end
    end
end
    
    %last section
    for i = colassign(colSecs):Nstory
        colNames(i) = [buildingName,'_C',num2str(colSecs)];
        if useIMKCalibration == 1
            load(colNames(i),'b','h');
            colArea(i) = b*h;
        else
            load(colNames(i),'A_ele')
            colArea(i) = A_ele;
        end
    end
    
% get beam dimensions
beamNames = strings(Nstory,1);
beamArea = zeros(Nstory,1);
for k = 1:beamSecs - 1
    % assign column section names and dimensions to the right floors
    for i = beamassign(k):beamassign(k+1) - 1
        beamNames(i) = [buildingName,'_B',num2str(k)];
        if useIMKCalibration == 1
            load(beamNames(i),'b','h');
            beamArea(i) = b*h;
        else
            load(beamNames(i),'A_ele')
            beamArea(i) = A_ele;
        end
    end
end
    
    %last section
    for i = beamassign(beamSecs):Nstory
        beamNames(i) = [buildingName,'_B',num2str(beamSecs)];
        if useIMKCalibration == 1
            load(beamNames(i),'b','h');
            beamArea(i) = b*h;
        else
            load(beamNames(i),'A_ele')
            beamArea(i) = A_ele;
        end
    end


% compute loads
% slab loads
Lframe = Nbay*Lbeam;
frame_area = Lframe*Lbeam;
Wslab = tslab*frame_area*RCdensity;
Wimp = DL_imp_perarea*frame_area;
LL = LL_perarea*frame_area;

slabDL_perL = (tslab*RCdensity + DL_imp_perarea)*Lbeam;
slabLL_perL = LL_perarea*Lbeam;

beamLL = slabLL_perL*Lbeam;

%LL_perarea = (2.4 + 0.72)*kN/m^2; %given in ASCE 7 as minimunm live load
% in an office building in the office area + partitions load

% factored load combinations
% consider the following combinations
% 1.2 D + 1.6 L
% 1.2 D + L + E or 1.2D + 0.5 L + E (if L < 4.78 kN/m2)
% 0.9 D + E

DL_fac = 1.2;
LL_fac = 0.5;

% if strcmp(buildingName,'10st') == 1
%     DL_fac = 1.0;
% end

for i = 1:Nstory
    % slab loads
    storyinfo(i).slabDL = Wslab + Wimp;
    storyinfo(i).slabLL = LL;
    
    % assign section info to data structure
    storyinfo(i).colName = colNames(i);
    storyinfo(i).colArea = colArea(i);
    storyinfo(i).beamName = beamNames(i);
    storyinfo(i).beamArea = beamArea(i);

% beam loads
    Wbeam_perL = RCdensity*storyinfo(i).beamArea;
    storyinfo(i).Wbeam = Wbeam_perL*Lbeam;
    storyinfo(i).Wbeams_flr = storyinfo(i).Wbeam*Nbay; %total factored beam load per floor
    
    % total factored beam load per length for the model
    %(includes beam DL and slabs)
    storyinfo(i).fac_beamUniform = DL_fac*(Wbeam_perL + slabDL_perL)+ LL_fac*slabLL_perL;
    
% column loads
    storyinfo(i).Wcol = RCdensity*storyinfo(i).colArea*storyinfo(i).Hcol;
    storyinfo(i).Wcols_flr = storyinfo(i).Wcol*Ncol;
    storyinfo(i).fac_colUniform = DL_fac*storyinfo(i).Wcol/storyinfo(i).Hcol;
        
end

% elaborate method (assign nodes based on tributary area rather than
    % uniformly
for i = 1:Nstory
    
     storyinfo(i).beamDL = storyinfo(i).Wbeam + slabDL_perL*Lbeam; %DL on the beam due to
     %its own weight and unfactored slab dead loads
     
    for j = 1:Nbay+1
        if j == 1 || j == Nbay+1
            beamLoadFact = 0.0;
        else
            beamLoadFact = 0.5;
        end
        
        % nodal weights
        if i == Nstory
           storyinfo(i).nodalWt(j) = 0.5*storyinfo(i).Wcol...
            + 0.5*storyinfo(i).beamDL + beamLoadFact*storyinfo(i).beamDL;
        else
        storyinfo(i).nodalWt(j) = 0.5*storyinfo(i).Wcol + 0.5*storyinfo(i+1).Wcol...
            + 0.5*storyinfo(i).beamDL + beamLoadFact*storyinfo(i).beamDL;
        end
        
        storyinfo(i).nodalmass(j) = storyinfo(i).nodalWt(j)/g;
        
        % column loads (factored)
        fac_beamload = DL_fac*storyinfo(i).beamDL + LL_fac*beamLL;
        fac_Wcol = DL_fac*storyinfo(i).Wcol;
        
        storyinfo(i).colload(j) = fac_Wcol + 0.5*fac_beamload + beamLoadFact*fac_beamload;
    end

    %storyinfo(i).weight = sum(storyinfo(i).nodalWt(:));
    storyinfo(i).weight = storyinfo(i).slabDL + storyinfo(i).Wbeams_flr + storyinfo(i).Wcols_flr;
    
%     if strcmp(buildingName,'60st') == 1 || strcmp(buildingName,'2st2') == 1 || strcmp(buildingName,'2st2PD') == 1
%         if strcmp(buildingName,'60st') == 1
%             storyinfo(i).weight = 1437.9;
%         end
%     
%         % overwrite some parameters for verification purposes
%         if strcmp(buildingName,'2st2') == 1 || strcmp(buildingName,'2st2PD') == 1
%             storyinfo(1).weight = 535.0;
%             storyinfo(2).weight = 525.0;
%         end
%     
%         % nodal loads and masses
%         storyinfo(i).nodalWt(1:Nbay+1) = storyinfo(i).weight/Ncol;
% %         if strcmp(buildingName,'6st') == 1
% %             storyinfo(i).nodalload(1:Nbay+1) = storyinfo(i).weight/Ncol/2;
% %         end
%         storyinfo(i).nodalmass(1:Nbay+1) = storyinfo(i).nodalload/g;
%     end
end

Wbuilding = sum([storyinfo(:).weight]);
Hbuilding = sum([storyinfo(:).Hcol]);
save([buildingName,'_info'],'Wbuilding','Hbuilding','Nstory','Nbay','-append')



% the total gravity loads are not needed in the model and load definition
% (but rather for the IMK component calibration)
% We will use the same dead and live load factors
for i = 1:Nstory
    % column total gravity loads (cumulative)
    for j = 1:Nbay + 1
        coltotload = 0.0;
        for k = i:Nstory
            coltotload = coltotload + storyinfo(k).colload(j);
        end
        storyinfo(i).coltotLoad(j) = coltotload;
    end
end
end


