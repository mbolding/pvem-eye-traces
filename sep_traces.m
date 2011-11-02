function s = sep_traces(Efull)
% sep runs into blocks, analyze, and plot them
clf
%% calc block size
blocksize = diff(Efull.block.t);
blockdelay = blocksize(1) * 0.01;
blocksize = blocksize(1) * 0.97; % block size in seconds, cut off a bit at end
blocksizeE = find(Efull.t>blocksize,1,'first'); % block size in idx
blocksizeT = find(Efull.T.t>blocksize,1,'first');

%% setup results structure
numblocks = length(Efull.block.type);
blocktypes = sort(unique(Efull.block.type));
numblocktypes = length(blocktypes);
for idx = 1:numblocktypes
    results.(blocktypes{idx}).idx = 0;
end
numrepeats = numblocks/numblocktypes;

%% analyze each block
for idx = 1:length(Efull.block.type)
    blocktype = Efull.block.type{idx};
    %% break data into blocks
    blockstart = Efull.block.t(idx) + blockdelay;
    blockRangeE = (1:blocksizeE) + find(Efull.t>blockstart,1,'first');
    blockRangeT = (1:blocksizeT) + find(Efull.T.t>blockstart,1,'first');
    
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
    sm = 50;
    switch(blocktype)
        case {'fix','sacc','spem'}
            E.C.sx = smooth(E.C.x,sm,'moving');
%             fprintf('%f %f %f %f %s\n' , min(E.t), max(E.t), min(E.C.sx), max(E.C.sx), Efull.block.type{idx})
        case {'vergtr','vergst'}
            E.V.sx = smooth(E.V.x,sm,'moving');
%             fprintf('%f %f %f %f %s\n' , min(E.t), max(E.t), min(E.V.sx), max(E.V.sx), Efull.block.type{idx})    
%             E.V.sx = smooth(E.V.x,0.01,'rlowess'); % slow but nice.
%             E.V.sx = smooth(E.V.x,sm,'sgolay'); % slow but nice.
    end
    
    %% flipped display :(
    if any(cell2mat(strfind({'734560','734595','734596','734602','734603'},Efull.name(1:6))))
        E.flipped = true;
        switch(blocktype)
            case {'fix','sacc','spem'}
            case {'vergtr','vergst'}
                E.T.x = -E.T.x;
        end
    else
        E.flipped = false;
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
    
    % data quality
    qual = sum(~isnan(E.V.x))/length(E.V.x);
    results.(blocktype).qual(blockidx) = qual;
    
    % rms error
    rms = sqrt(nanmean((E.T.xx - E.C.sx).^2))/2;
    results.(blocktype).rms(blockidx) = rms;
    
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
    subplot(numrepeats,numblocktypes,idx)
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
    title(sprintf('%.2f, %.1f, %.2f, %.2f', ...
        qual, rms, r(2), p(2)),'FontSize',8);
    drawnow
end

axes('Position',[0.2 0.03 0.6 0.05],'Xlim',[0 1],'Ylim',[0 1],'Visible','off');
text(0.5,0.5,[ Efull.name '  ' Efull.stim ])

%% print results
% fprintf('run_name\tstim\ttype\tmeanRMS\tmeanR\tmeanP\tmeanQ\n');
s = '';
for idx = 1:length(blocktypes)
    blocktype = blocktypes{idx};
    meanrms = mean(results.(blocktype).rms);
    meanR = mean(abs(results.(blocktype).r));
    meanP = mean(results.(blocktype).p);
    meanQ = mean(results.(blocktype).qual);
    s = [s sprintf('%-11s\t%s\t%s\t%.3f\t%.3f\t%.3f\t%.2f\n', ...
        Efull.name, Efull.stim(1:3), blocktype, meanrms, meanR, meanP, meanQ)];
%     fprintf(s);
end
