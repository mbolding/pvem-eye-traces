function sep_traces(Efull)
% sep runs into blocks and plot them
clf
%% calc block size
blocksize = diff(Efull.block.t);
blocksize = blocksize(1); % block size in seconds
blocksizeE = find(Efull.t>blocksize,1,'first'); % block size in idx
blocksizeT = find(Efull.T.t>blocksize,1,'first');

%% setup results structure
blocktypes = sort(unique(Efull.block.type));
for idx = 1:length(blocktypes)
    results.(blocktypes{idx}).idx = 0;
end

%% analyze each block
for idx = 1:length(Efull.block.type)
    blocktype = Efull.block.type{idx};
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
    switch(blocktype)
        case {'fix','sacc','spem'}
            E.C.sx = smooth(E.C.x,sm,'moving');
%             fprintf('%f %f %f %f %s\n' , min(E.t), max(E.t), min(E.C.sx), max(E.C.sx), Efull.block.type{idx})
        case {'vergtr','vergst'}
            E.V.sx = smooth(E.V.x,sm,'moving');
%             fprintf('%f %f %f %f %s\n' , min(E.t), max(E.t), min(E.V.sx), max(E.V.sx), Efull.block.type{idx})    
%             E.V.sx = smooth(E.V.x,0.05,'loess'); % slow but nice.
    end
    
    %% interp target motion to match eye trace sample rate
    switch(blocktype)
        case 'fix'
            E.T.xx = ones(size(E.C.x)) * E.T.x(1);
        case {'sacc','vergst'}
            E.T.xx = interp1(E.T.t,E.T.x,E.t,'nearest');
        case {'spem','vergtr'}
            E.T.xx = interp1(E.T.t,E.T.x,E.t);
    end
    
    %% measure tracking accuracy various ways
    blockidx = results.(blocktype).idx + 1;
    results.(blocktype).idx = blockidx;
    
    % rms error
    results.(blocktype).rms(blockidx) = sqrt(nanmean((E.T.xx - E.C.sx).^2));
    
    % correlation coef and p
    E.C.sxn = E.C.sx;
    E.T.xxn = E.T.xx;
    E.C.sxn(isnan(E.C.sxn)) = 0; % corrcoef cannot handle nans, could use nancov?
    E.T.xxn(isnan(E.T.xxn)) = 0;
    [r, p] = corrcoef(E.T.xxn, E.C.sxn);
    results.(blocktype).r(blockidx) = r(2);
    results.(blocktype).p(blockidx) = p(2);
    
    % movement specific analysis
    switch(blocktype)
        case 'fix'
        case 'spem'
        case 'sacc'
        case 'vergtr'
        case 'vergst'
    end
    
    %% plot data
    switch(blocktype)
        case {'fix','sacc','spem'}
            Yrng = [-12 12];
            plot(E.t,E.T.xx,'k:',E.t,E.C.sx,'m')
        case {'vergtr','vergst'}
            Yrng = [-2 2];
            plot(E.t,E.T.xx,'k:',E.t,E.V.sx,'b')
        otherwise
            plot(E.t,E.T.xx,'k:',E.t,E.V.sx,'b',E.t,E.L.sx,'r',E.t,E.R.sx,'g')
    end
    ylim(Yrng)
    Xrng = [0 20];
    xlim(Xrng)
    drawnow
    title(blocktype)
end


for idx = 1:length(blocktypes)
    blocktype = blocktypes{idx};
    disp(blocktype)
    disp(results.(blocktype).idx)
    disp(mean(results.(blocktype).rms))
    disp(results.(blocktype).r)
    disp(results.(blocktype).p)
end
