function [] = plot_drift_envelopes(plot_ind,Nstory,maxIDrifts,BDrifts,saveSpecify)
%UNTITLED5 Summary of this function goes here

% %Plot drift envelopes at select stations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(plot_ind)
figure;
barh(1:Nstory,maxIDrifts(:,plot_ind(i))*100)
xlabel('Peak Interstory Drift Envelope(%)')
ylabel('Story')
title(BDrifts(plot_ind(i)).name,'interpreter','none')
xlim([0,inf])
set(gca,'FontSize',14)

GMname = BDrifts(plot_ind(i)).name;
print (['idriftenv_',char(GMname),saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['idriftenv_',char(GMname),saveSpecify,'.emf'],'-dmeta')

end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

