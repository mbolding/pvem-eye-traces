function plot_traces(E)

%% smooth data
E.L.sx = smooth(E.L.x,100,'moving');
E.R.sx = smooth(E.R.x,100,'moving');
E.V.sx = smooth(E.V.x,100,'moving');

%% plot data
Yrng = [-20 20];
plot(E.T.t,E.T.x,'k:',E.t,E.V.sx,'b',E.t,E.L.sx,'r',E.t,E.R.sx,'g')
title([E.name ' : ' datestr(str2num(E.name)) ' : ' E.stim])
ylim(Yrng)
hold on
for idx = 1:length(E.trialstarts)
    plot([1 1]*E.trialstarts(idx),Yrng,'g--')
    plot([1 1]*E.trialends(idx),Yrng,'r--')
end

for idx = 1:length(E.block.t)
    plot([1 1]*E.block.t(idx),Yrng,'k:')
    text(E.block.t(idx),max(Yrng)-10,E.block.type(idx),'Rotation',90)
end
hold off
xlim([min(E.t) max(E.t)])
