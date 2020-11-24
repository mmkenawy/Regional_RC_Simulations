
function [sd,sv,sa] = spectrum(gacc,npnts,delt,beta,periods)
% Generate the absolute acceleration, relative velocity and relative
% displacement response spectrum for a ground motion

specPts = length(periods);

sd = zeros(specPts,1);
sv = zeros(specPts,1);
sa = zeros(specPts,1);
% loop over period range
for j = 1:specPts
    per = periods(j);
    [sd(j),sv(j),sa(j)] = integrate(per,delt,npnts,beta,gacc);
end



