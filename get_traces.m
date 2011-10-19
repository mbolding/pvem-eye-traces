function E = get_traces(filename)
% E = get_traces(filename)
% loads traces from converted eyelink edf files
% assumes samples are in 'samples' subdir
% assumes events are in 'events' subdir
% needs shell commands so should run on osx or linux, but will need mods 
% for windows.
%
% event conversion example:
% edf2asc_s -e -p events rawdata/*/*.edf
% sample conversion:
% edf2asc_s -s -sh -p samples rawdata/1005/*.edf 
% 
% E.L left eye
% E.R right eye
% E.T target
%
% mbolding@uab.edu 22 Feb 2011

if ~exist('filename','var') % ask for filename if not supplied on command line
    [filename] = uigetfile('*.asc');
end

%% screen FIXME read these out of event file instead.
screen.width = 40;
screen.dist = 100;
screen.pixelwidth = 800;
base.freq = 1000; % data in file in ms

[~,E.name,] = fileparts(filename) ;

%% load samples
samplefilename = ['samples/' filename];
fid = fopen(samplefilename);
frewind(fid) ; 
A = textscan(fid,'%f %f %f %f %f %f %f %s','CollectOutput', 1, 'treatAsEmpty', {'.','I','C','R'});

%% calculate traces
E.start = min(A{1,1}(1:10,1))/base.freq;
E.t = A{1,1}(:,1)/base.freq - E.start;
E.L.x = atand((screen.width*A{1,1}(:,2)/screen.pixelwidth)/screen.dist) - atand(screen.width/screen.dist)/2;
E.R.x = atand((screen.width*A{1,1}(:,5)/screen.pixelwidth)/screen.dist) - atand(screen.width/screen.dist)/2;
E.R.x = E.R.x - nanmean(E.R.x);
E.L.x = E.L.x - nanmean(E.L.x);
E.V.x = (E.R.x - E.L.x)/2;

%% load target motion
copyfile(['events/' filename], 'temp.asc')
!grep FIXPOINT temp.asc  | awk '{ print $2 " " $11  }' > fixpointtemp.txt
temp = load('fixpointtemp.txt');
E.T.t = temp(:,1)/base.freq - E.start;
E.T.x = atand((screen.width*temp(:,2)/screen.pixelwidth)/screen.dist) - atand(screen.width/screen.dist)/2;
E.T.x = E.T.x - nanmean(E.T.x);

!grep TRIALID temp.asc  | awk '{ print $2 }' > fixpointtemp.txt
E.trialstarts = load('fixpointtemp.txt');
E.trialstarts = E.trialstarts/base.freq - E.start;
!grep TRIAL_RESULT temp.asc  | awk '{ print $2 }' > fixpointtemp.txt
E.trialends = load('fixpointtemp.txt');
E.trialends = E.trialends/base.freq - E.start;

%% load blocks and attn task
[~,blockstr]=system('grep BLOCKSYNC temp.asc | awk ''{ print $2, $4 }''');
[~,attnstr]=system('grep attn temp.asc | awk ''{ print $2, $5 }''');

%% parse blocks and attn
blockstr = textscan(blockstr,'%f %s');
E.block.t = blockstr{1}/base.freq - E.start;
E.block.type = blockstr{2};

if isempty(attnstr)
    E.stim = 'CSM';
else
    E.stim = 'solid';
    attnstr = textscan(attnstr,'%f %s');
    E.attn.t = attnstr{1};
    E.attn.str = attnstr{2};
end


%% clean up
fclose('all');

%% plot it
plot_traces(E)

%% save the data
save(['mats/' E.name '.mat'],'E')
