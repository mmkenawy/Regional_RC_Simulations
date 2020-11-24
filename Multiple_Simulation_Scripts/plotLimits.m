function [idrift_lim, bdrift_lim, SA_lim, SV_lim, PGV_lim] = plotLimits(buildingName)
% controlled limits for plots of different buildings

if strcmp(buildingName,'3st') == 1
    % 3st plot limits
    idrift_lim = 8.1;
    bdrift_lim = 7;
    SA_lim = 4.2;
    SV_lim = 5;
    PGV_lim = 3.5;
elseif strcmp(buildingName,'12st') == 1
    % 12 story plot limits
    idrift_lim = 5.8; %12 story
    bdrift_lim = 3;
    SA_lim = 1.2;
    SV_lim = 5;
    PGV_lim = 3.5;
end