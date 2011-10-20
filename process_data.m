function process_data()
% run sep_traces on all the data

clf

%% get files
datafiles = dir('mats/*.mat');
numfiles = length(datafiles);
idx = 0;
fp = fopen('results.txt','w');

%% user feedback
h = waitbar(idx,'processing');
fprintf('run_name\tstim\ttype\tmeanRMS\tmeanR\tmeanP\tmeanQ\n');

%% process each file
for f = datafiles'
    idx = idx + 1;
    waitbar(idx/numfiles)
    load(['mats/' f.name])
    s = sep_traces(E);
    fprintf(s)
    fprintf(fp,s);
end

%% cleanup
delete(h)
fclose(fp);