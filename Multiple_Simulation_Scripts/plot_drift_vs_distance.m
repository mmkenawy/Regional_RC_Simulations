function [] = plot_drift_vs_distance(FPdist,FNdist,maxBDrift,maxIDrift_GM,...
    Xstations,Ystations,buildingName,saveSpecify)
% this function plots relationships between building drifts and fault
% distances

% plot limits for each building
[idrift_lim, bdrift_lim, ~,~,~] = plotLimits(buildingName);
pointsize = 50;

% drift envelope vs fault parallel distance
maxIDrift_FPdist = zeros(Xstations,1);
X = reshape(FPdist,Xstations,Ystations);
Y = reshape(maxIDrift_GM,Xstations,Ystations);
for i = 1:Xstations
        maxIDrift_FPdist(i) = max(Y(i,:));
end
figure;
plot(X(:,1),maxIDrift_FPdist*100,'LineWidth',3,'color',[0.543 0 0])
set(gca,'FontSize',14)
xlabel('Distance Parallel to Fault (km)')
ylabel('Maximum Interstory Drift Envelope (%)')
ylim([0,inf])

print (['idrift_max_FP_',saveSpecify,'.pdf'],'-dpdf','-fillpage')
print (['idrift_max_FP_',saveSpecify,'.emf'],'-dmeta')

% drift envelope vs fault normal distance
maxIDrift_FNdist = zeros(Ystations,1);
X = reshape(FNdist,Xstations,Ystations);
Y = reshape(maxIDrift_GM,Xstations,Ystations);
for i = 1:Ystations
        maxIDrift_FNdist(i) = max(Y(:,i));
end
figure;
plot(X(1,:),maxIDrift_FNdist*100,'LineWidth',3,'color',[0.543 0 0])
set(gca,'FontSize',14)
xlabel('Distance Normal to Fault (km)')
ylabel('Maximum Interstory Drift Envelope (%)')
ylim([0,inf])

print (['idrift_max_FN_',saveSpecify,'.pdf'],'-dpdf','-fillpage')
print (['idrift_max_FN_',saveSpecify,'.emf'],'-dmeta')


% all building drifts against fault normal distance
figure;
scatter(FNdist,maxBDrift*100,pointsize,FPdist,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
c = colorbar;
c.Label.String = 'Distance Parallel to Fault (km)';
xlabel('Distance Normal to Fault (km)')
ylabel('Peak Building Drift (%)')
%ylim([0,inf])
ylim([0,bdrift_lim])

print (['bdrift_Ndist',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['bdrift_Ndist',saveSpecify,'.emf'],'-dmeta')

% maximum interstory drift against fault normal distance
figure;
scatter(FNdist,maxIDrift_GM*100,pointsize,FPdist,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
c = colorbar;
c.Label.String = 'Distance Parallel to Fault (km)';
xlabel('Distance Normal to Fault (km)')
ylabel('Maximum Interstory Drift (%)')
%ylim([0,inf])
ylim([0,idrift_lim])

print (['idrift_Ndist',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['idrift_Ndist',saveSpecify,'.emf'],'-dmeta')

% all building drifts against fault parallel distance
figure;
scatter(FPdist,maxBDrift*100,pointsize,FNdist,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
c = colorbar;
c.Label.String = 'Distance Normal to Fault (km)';
xlabel('Distance Parallel to Fault (km)')
ylabel('Peak Building Drift (%)')
%ylim([0,inf])
ylim([0,bdrift_lim])

print (['bdrift_Pdist',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['bdrift_Pdist',saveSpecify,'.emf'],'-dmeta')

% building drift against fault normal distance
figure;
scatter(FPdist,maxIDrift_GM*100,pointsize,FNdist,'filled','Marker','o'...
    ,'MarkerEdgeColor','k')
set(gca,'FontSize',18)
c = colorbar;
c.Label.String = 'Distance Normal to Fault(km)';
xlabel('Distance Parallel to the Fault (km)')
ylabel('Maximum Interstory Drift (%)')
%ylim([0,inf])
ylim([0,idrift_lim])

print (['idrift_Pdist',saveSpecify,'.pdf'],'-dpdf','-bestfit')
print (['idrift_Pdist',saveSpecify,'.emf'],'-dmeta')

end

