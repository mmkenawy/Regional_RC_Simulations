function [] = plot_drift_vs_distance_color(xparam,xaxisLabel,maxBDrift,maxIDrift_GM,coloParam,...
    colorMap,colorLabel,plotLim,tickLocs,tickLabels,buildingName,saveSpecify,fileMarker)
% plot all building drifts against some distance metric
% plot limits for each building
[idrift_lim, bdrift_lim, ~,~,~] = plotLimits(buildingName);
pointsize = 50;

figure;
scatter(xparam,maxBDrift*100,pointsize,coloParam,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
colormap(colorMap)
c = colorbar;
c.Label.String = colorLabel;

caxis([0,plotLim])
c.Ticks = tickLocs;
c.TickLabels = tickLabels;

xlabel(xaxisLabel)
ylabel('Peak Building Drift (%)')
%ylim([0,inf])
ylim([0,bdrift_lim])

print (['bdrift_',fileMarker,saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['bdrift_',fileMarker,saveSpecify,'.emf'],'-dmeta')

% maximum interstory drift against fault normal distance
figure;
scatter(xparam,maxIDrift_GM*100,pointsize,coloParam,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
colormap(colorMap)
c = colorbar;
c.Label.String = colorLabel;

caxis([0,plotLim])
c.Ticks = tickLocs;
c.TickLabels = tickLabels;

xlabel(xaxisLabel)
ylabel('Maximum Interstory Drift (%)')
%ylim([0,inf])
ylim([0,idrift_lim])

print (['idrift_',fileMarker,saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['idrift_',fileMarker,saveSpecify,'.emf'],'-dmeta')
end

