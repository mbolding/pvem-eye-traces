function process_data()
% run sep_traces on all the preprocessed data in the mats directory

clf

%% get files
datafiles = dir('mats/*.mat');
numfiles = length(datafiles);
idx = 0;
fp = fopen('results.txt','w');

%% user feedback
% h = waitbar(idx,'processing');
fprintf(fp,'run\ttarget\ttask\trms\tr\tp\tq\n');

%% process each file
for f = datafiles'
    idx = idx + 1;
%     waitbar(idx/numfiles)
    load(['mats/' f.name])
    s = sep_traces(E);
    fprintf(s)
    fprintf(fp,s);
    reply = input('print me?','s');
    if reply == 'y'
        print('-dpdf',['pdfs/' f.name '.pdf'])
    end
end

%% cleanup
%  delete(h)
fclose(fp);