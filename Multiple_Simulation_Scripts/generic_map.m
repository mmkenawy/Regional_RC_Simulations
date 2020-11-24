function [mymap,levels,plotLim,ticklabels] = generic_map(FPdistance,FNdistance,param,...
    buildingName,saveSpecify,eqsource,Xstations,Ystations)

% create hazard color map

X = reshape(FPdistance,Xstations,Ystations);
Y = reshape(FNdistance,Xstations,Ystations);
Z = reshape(param,Xstations,Ystations);

%plotLim = 3; % you can play around with the plot limit here.

[levels,mymap,plotLim] = pulsecolors(param);

%ctot = c1 + c2 + c3 + c4 + c5 +c6;

figure;
contourf(X,Y,Z,levels,'LineStyle','none');
%pcolor(X,Y,Z)
hold on
plot([19,82],[10,10],'k','LineWidth',6)
plot(eqsource(1),eqsource(2),'p','MarkerEdgeColor','black',...
    'MarkerFaceColor','white','MarkerSize',20);
set(gca,'DataAspectRatio',[1 1 1])
%shading interp;
%equalmap = [0 0.5 0; 1 1 0; 1 0.5 0; 1 0 0];

colormap(mymap)
cb =colorbar('southoutside');
caxis([0,plotLim])
cb.Ticks = [levels,plotLim];
cb.TickLabels = {'','',num2str(levels(3),'%.1f'),...
    num2str(levels(4),'%.1f'),num2str(levels(5),'%.1f'),num2str(plotLim,'%.1f')};
ticklabels = cb.TickLabels;
cb.TickLength = 0.0;
% cb.TickLabels = {'','elastic','moderate damage',...
%    'severe damage','collapse'};
cb.Label.String = 'Normalized pulse period T_p/T_1';
cb.Label.FontSize = 16;
xlabel('X Coordinate (km)')
ylabel('Y Coordinate (km)')
set(gca,'FontSize',16)
xlim([0,100])
ylim([0,40])

print (['pulseMap',saveSpecify,'.pdf'],'-dpdf','-fillpage')
print (['pulseMap',saveSpecify,'.emf'],'-dmeta')
end