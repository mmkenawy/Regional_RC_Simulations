function [] = plot_drift_IMs(colorParam,maxBDrift,maxIDrift_GM,...
    SA_T1,SV_T1,PGV,buildingName,saveSpecify,mymap,colorLabel)
% this function plots the building demands vs ground motion intensity
% measures

% plot limits for each building
[idrift_lim, bdrift_lim, SA_lim, SV_lim, PGV_lim] = plotLimits(buildingName);

pointsize = 50;

% plot the building drifts against SA(T1)
figure;
scatter(maxBDrift*100,SA_T1,pointsize,colorParam,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
set(gca, 'YScale', 'log')
set(gca, 'xScale', 'log')
colormap(mymap)
c = colorbar;
c.Label.String = colorLabel;
ylabel('Spectral Acceleration at T_1 (g)')
xlabel('Peak Building Drift (%)')
%xlim([0,inf])
xlim([0,inf])
ylim([0,inf])

print (['bdrift_SA',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['bdrift_SA',saveSpecify,'.emf'],'-dmeta')

% plot the maximum interstory drifts against SA(T1)
figure;
scatter(maxIDrift_GM*100,SA_T1,pointsize,colorParam,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
set(gca, 'YScale', 'log')
set(gca, 'xScale', 'log')
colormap(mymap)
c = colorbar;
c.Label.String = colorLabel;
ylabel('Spectral Acceleration at T_1 (g)')
xlabel('Maximum Interstory Drift (%)')
%xlim([0,inf])
xlim([0,idrift_lim])
ylim([0,SA_lim])

print (['idrift_SA',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['idrift_SA',saveSpecify,'.emf'],'-dmeta')


% plot the building drifts against SV(T1)
figure;
scatter(maxBDrift*100,SV_T1,pointsize,colorParam,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
set(gca, 'YScale', 'log')
set(gca, 'xScale', 'log')
colormap(mymap)
c = colorbar;
c.Label.String = colorLabel;
ylabel('Spectral Velocity at T_1 (m/s)')
xlabel('Peak Building Drift (%)')
%xlim([0,inf])
xlim([0,bdrift_lim])
ylim([0,SV_lim])

print (['bdrift_SV',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['bdrift_SV',saveSpecify,'.emf'],'-dmeta')

% plot the maximum interstory drifts against SV(T1)
figure;
scatter(maxIDrift_GM*100,SV_T1,pointsize,colorParam,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
set(gca, 'YScale', 'log')
set(gca, 'xScale', 'log')
colormap(mymap)
c = colorbar;
c.Label.String = colorLabel;
ylabel('Spectral Velocity at T_1 (m/s)')
xlabel('Maximum Interstory Drift (%)')
%xlim([0,inf])
xlim([0,idrift_lim])
ylim([0,SV_lim])

print (['idrift_SV',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['idrift_SV',saveSpecify,'.emf'],'-dmeta')


% plot the maximum interstory drifts against PGV
figure;
scatter(maxIDrift_GM*100,PGV,pointsize,colorParam,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
set(gca, 'YScale', 'log')
set(gca, 'xScale', 'log')
colormap(mymap)
c = colorbar;
c.Label.String = colorLabel;
ylabel('Peak Ground Velocity (m/s)')
xlabel('Maximum Interstory Drift (%)')
%xlim([0,inf])
xlim([0,idrift_lim])
ylim([0,PGV_lim])

print (['idrift_PGV',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['idrift_PGV',saveSpecify,'.emf'],'-dmeta')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

