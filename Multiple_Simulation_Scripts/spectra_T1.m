function [SA_T1,SV_T1] = spectra_T1(structPeriod,GMset,component)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([GMset,component,'_SA_SV_PGV'],'periods','spectra')

numGMs = length(spectra);
SA_T1 = zeros(numGMs,1);
SV_T1 = zeros(numGMs,1);

for i = 1:numGMs
    SA_T1(i) = interp1(periods,spectra(i).sa_g,structPeriod);
    SV_T1(i) = interp1(periods,spectra(i).sv,structPeriod);
end
    
% save([buildingName,'_SA_SV_',GMset,component],'SA_T1','SV_T1')