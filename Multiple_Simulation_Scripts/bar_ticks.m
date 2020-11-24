function [plotLim,tickLocs,tickLabels] = bar_ticks(vector)
%decide tick locations and labels for a color bar
plotLim = round(max(vector),-1);
tickLocs = [plotLim/4, plotLim/4*2, plotLim/4*3, plotLim];
tickLabels = [plotLim/4, plotLim/4*2, plotLim/4*3, plotLim];
end

