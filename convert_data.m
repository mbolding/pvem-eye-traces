function convert_data()
clf
datafiles = dir('events/*.asc');
numfiles = length(datafiles);
idx = 0;
h = waitbar(idx,'processing');
for f = datafiles'
    idx = idx + 1;
    waitbar(idx/numfiles)
    get_traces(f.name);
end
delete(h)