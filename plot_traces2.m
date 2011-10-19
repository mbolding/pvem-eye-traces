function plot_traces2(E,type)
% plot single blocks of data

%% smooth data
sm = 10;


%% plot data
Yrng = [min(E.T.x) max(E.T.x)] + [-2 2];

switch(type)
    case 'fix'
        E.C.sx = smooth(E.C.x,sm,'moving');
        plot(E.T.t,E.T.x,'k:',E.t,E.C.sx,'m')
    case 'sacc'
        E.C.sx = smooth(E.C.x,sm,'moving');
        plot(E.T.t,E.T.x,'k:',E.t,E.C.sx,'m')
    case 'spem'
        E.C.sx = smooth(E.C.x,sm,'moving');
        plot(E.T.t,E.T.x,'k:',E.t,E.C.sx,'m')
    case 'vergtr'
        E.V.sx = smooth(E.V.x,0.02,'loess');
        plot(E.T.t,E.T.x,'k:',E.t,E.V.sx,'b')
    case 'vergst'
        E.V.sx = smooth(E.V.x,0.02,'loess');
        plot(E.T.t,E.T.x,'k:',E.t,E.V.sx,'b')
    otherwise
        plot(E.T.t,E.T.x,'k:',E.t,E.V.sx,'b',E.t,E.L.sx,'r',E.t,E.R.sx,'g')
end

ylim(Yrng)
xlim([min(E.t) max(E.t)])
