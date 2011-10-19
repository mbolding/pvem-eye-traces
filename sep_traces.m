function sep_traces(Efull)
% sep runs into blocks and plot them

%% calc block size
blocksize = diff(Efull.block.t);
blocksize = blocksize(1); % block size in seconds
blocksizeE = find(Efull.t>blocksize,1,'first'); % block size in idx
blocksizeT = find(Efull.T.t>blocksize,1,'first');

for idx = 1:length(Efull.block.type)
    subplot(4,5,idx)
    %% break data into blocks
    blockRangeE = (1:blocksizeE) + find(Efull.t>Efull.block.t(idx),1,'first');
    blockRangeT = (1:blocksizeT) + find(Efull.T.t>Efull.block.t(idx),1,'first');
    
    E.t = Efull.t(blockRangeE);
    E.t = E.t - E.t(1);
    E.R.x = Efull.R.x(blockRangeE);
    E.L.x = Efull.L.x(blockRangeE);
    
    E.T.t = Efull.T.t(blockRangeT);
    E.T.t = E.T.t - E.T.t(1);
    E.T.x = Efull.T.x(blockRangeT);
    
    %% calculate conjugate and disconjugate eye movements
    E.V.x = (E.R.x - E.L.x)/2;
    E.C.x = (E.R.x + E.L.x)/2;
    
    %% filter data
    sm = 10;
    switch(Efull.block.type{idx})
        case {'fix','sacc','spem'}
            E.C.sx = smooth(E.C.x,sm,'moving');
        case {'vergtr','vergst'}
            E.V.sx = smooth(E.V.x,sm,'moving');
%             E.V.sx = smooth(E.V.x,0.05,'loess'); % slow but nice.
        otherwise
    end
    
    %% interp target motion to match eye trace sample rate
    switch(Efull.block.type{idx})
        case 'fix'
            E.T.xx = ones(size(E.C.x)) * E.T.x(1);
        case {'sacc','vergst'}
            E.T.xx = interp1(E.T.t,E.T.x,E.t,'nearest');
        case {'spem','vergtr'}
            E.T.xx = interp1(E.T.t,E.T.x,E.t);
    end
    
    %% plot data
    Yrng = [min(E.T.x) max(E.T.x)] + [-2 2];
    switch(Efull.block.type{idx})
        case {'fix','sacc','spem'}
            plot(E.t,E.T.xx,'k:',E.t,E.C.sx,'m')
        case {'vergtr','vergst'}
            plot(E.t,E.T.xx,'k:',E.t,E.V.sx,'b')
        otherwise
            plot(E.t,E.T.xx,'k:',E.t,E.V.sx,'b',E.t,E.L.sx,'r',E.t,E.R.sx,'g')
    end
    ylim(Yrng)
    xlim([min(E.t) max(E.t)])
    drawnow
    title(Efull.block.type{idx})
end

