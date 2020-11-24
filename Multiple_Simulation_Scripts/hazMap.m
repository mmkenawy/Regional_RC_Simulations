function [mymap,damStates] = hazMap(FPdistance,FNdistance,maxIDrift_GM,...
    buildingName,saveSpecify,eqsource,Xstations,Ystations)

% create hazard color map

X = reshape(FPdistance,Xstations,Ystations);
Y = reshape(FNdistance,Xstations,Ystations);
Z = reshape(maxIDrift_GM.*100,Xstations,Ystations);

plotLim = round(max(maxIDrift_GM)*100,0);
%plotLim = 4.5; % play around with plot limit here.

% damage drift limits
elastic = 0.5;
moderateDam = 1.0;
extenDam = 1.5;
severeDam = 2.5;
collapse = plotLim - 0.25;
damStates = [0.0,elastic,moderateDam,extenDam,severeDam,collapse];

c1 = 2;
c2 = (moderateDam - elastic)/elastic*c1;
c3 = (extenDam - moderateDam)/elastic*c1;
c4 = (severeDam - extenDam)/elastic*c1;
c5 = (collapse - severeDam)/elastic*c1;
c6 = (plotLim - collapse)/elastic*c1;
%ctot = c1 + c2 + c3 + c4 + c5 +c6;

figure;
contourf(X,Y,Z,damStates,'LineStyle','none');
%pcolor(X,Y,Z)
hold on
plot([19,82],[10,10],'k','LineWidth',6)
plot(eqsource(1),eqsource(2),'p','MarkerEdgeColor','black',...
    'MarkerFaceColor','white','MarkerSize',20);
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'FontSize',18)
%shading interp;
%equalmap = [0 0.5 0; 1 1 0; 1 0.5 0; 1 0 0];
mymap = [ repmat([0 0.5 0],c1,1)
        repmat([1 1 0],c2,1)
        repmat([1 0.5 0],c3,1)
        repmat([1 0 0],c4,1)
        repmat([0.5 0 0],c5,1)
        repmat([0.25 0 0],c6,1)];
colormap(mymap)
cb = colorbar('southoutside');
caxis([0,plotLim])
cb.Ticks = [damStates,plotLim];
% cb.TickLabels = {num2str(damStates(1),'%.1f'),num2str(damStates(2),'%.1f'),...
%     num2str(damStates(3),'%.1f'),num2str(damStates(4),'%.1f'),...
%      num2str(damStates(5),'%.1f'),num2str(collapse,'%.1f')};
 cb.TickLabels = {'',num2str(damStates(2),'%.1f'),...
    '',num2str(damStates(4),'%.1f'),...
     num2str(damStates(5),'%.1f'),num2str(collapse,'%.1f'),''};
cb.TickLength = 0.0;
% cb.TickLabels = {'','elastic','moderate damage',...
%    'severe damage','collapse'};
cb.Label.String = 'Maximum Interstory Drift (%)';
%cb.Label.FontSize = 18;
xlabel('X Coordinate (km)')
ylabel('Y Coordinate (km)')
xlim([0,100])
ylim([0,40])

print (['hazMap',saveSpecify,'.pdf'],'-dpdf','-fillpage')
print (['hazMap',saveSpecify,'.emf'],'-dmeta','-painters')
end