function [] = plot_drift_envelope_vs_distance(FPdist,FNdist,maxBDrift,maxIDrift_GM,...
    Xstations,Ystations,buildingName,saveSpecify)
% this function plots relationships between building drifts and fault
% distances

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

end

