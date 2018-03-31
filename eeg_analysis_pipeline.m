clear variables;

% define variables with path names
dir_main = 'D:\Mind & Brain\EEG Kurs\';
dir_data = [dir_main 'EEG Daten Antonia\']; % 
% assure fieldtrip is in path
addpath('D:\Mind & Brain\EEG Kurs\fieldtrip-20180328');
ft_defaults;

 % matrix with subject names
name_subj = struct2cell(dir(dir_data));
 % get names from eeg files
name_subj = name_subj(1,cellfun('isempty',strfind(name_subj(1,:),'.eeg'))==0);
 % throw out '.eeg', only leaves subject name
name_subj = regexprep(name_subj,'.eeg','');

% make single subject variable
subject = name_subj{1};

% make variables for header and eeg file
headerfile   = [dir_data subject '.vhdr'];
eegfile     = [dir_data subject '.eeg'];

%% preprocessing

% read data in
cfg = [];
cfg.dataset = headerfile;
data_raw = ft_preprocessing(cfg);

% plot raw data
% plot(data_raw.time{1}, data_raw.trial{1}(:,:))

% rereference to M2
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = {'M2'};
data_reref = ft_preprocessing(cfg, data_raw);

% % plot re-referenced data
% figure;
% plot(data_reref.time{1}, data_reref.trial{1}(:,:))

%% exercise

% % try different high-pass filters and plot the data
% cutoff_hp = [0.1 1 10];
% cfg = [];
% cfg.hpfilter = 'yes';
% cfg.hpfilttype = 'firws';
% cfg.hpfiltdir = 'onepass-zerophase';
% cfg.hpinstabilityfix = 'no';
% for i = 1:length(cutoff_hp)
% 	cfg.hpfreq = cutoff_hp(i);
%     cfg.hpfiltdf = cfg.hpfreq;
% 	data_hp = ft_preprocessing(cfg, data_reref);
% 	figure;
% 	plot(data_hp.time{1}, data_hp.trial{1}(:,:))
% end
% 
% % try different low-pass filters and plot the data
% cutoff_lp = [10 20 30 100];
% cfg = [];
% cfg.lpfilter = 'yes';
% cfg.hpfilttype = 'firws';
% cfg.hpfiltdir = 'onepass-zerophase';
% cfg.hpinstabilityfix = 'no';
% cfg.hpfiltdf = 5;
% for i = 1:length(cutoff_lp)
% 	cfg.lpfreq = cutoff_lp(i);
% 	data_lp = ft_preprocessing(cfg, data_reref);
% 	figure;
% 	plot(data_lp.time{1}, data_lp.trial{1}(:,1))
% end

%% preprocessing (continued)

% high-pass filter with the "final" options
cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfreq = 0.1;
cfg.hpfilttype = 'firws';
cfg.hpfiltdir = 'onepass-zerophase';
cfg.hpinstabilityfix = 'no';
cfg.hpfiltwintype = 'kaiser';
data_hp = ft_preprocessing(cfg, data_reref);
% 
% % plot high-pass filtered data
figure;
plot(data_hp.time{1}, data_hp.trial{1}(:,:))


% low-pass filter with the "final" options
cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfilter = 30;
cfg.hpfilttype = 'firws';
cfg.hpfiltdir = 'onepass-zerophase';
cfg.hpinstabilityfix = 'no';
cfg.hpfiltdf = 5;
data_lp = ft_preprocessing(cfg, data_hp);

% plot low-pass filtered data
figure;
plot(data_lp.time{1}, data_lp.trial{1}(:,:))

% look at triggers
cfg = [];
cfg.trialdef.eventtype  = '?';
cfg.headerfile   = headerfile;
cfg.datafile     = eegfile;
ft_definetrial(cfg);

% define trials
cfg = [];
cfg.headerfile = headerfile;
cfg.dataset = eegfile;
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S115', 'S116', 'S125', 'S126', 'S135', 'S136'...
    'S145', 'S146', 'S215', 'S216', 'S225', 'S226', 'S235', 'S236'...
    'S245', 'S246'};
cfg.trialdef.prestim = 0.2;
cfg.trialdef.poststim = 1;
cfg_deftrial = ft_definetrial(cfg);

% apply trial definition to data
data_segmented = ft_redefinetrial(cfg_deftrial, data_lp);

%% artifact rejection

% display data in databrowser for manual rejection
cfg = [];
cfg.viewmode = 'vertical';
artf=ft_databrowser(cfg,data_segmented);

 % artifact rejection: now the arifacts that were highlighted are removed
 % from the data
 cfg = [];
 cfg.artfctdef.reject = 'complete';
 % rejection of visual artifacts
 cfg.artfctdef.visual.artifact = artf.artfctdef.visual.artifact;
 
 data_clean = ft_rejectartifact(cfg,data_segmented);

%% ICA
    
% exclude bipolar EOG electrodes (not independent)
cfg = [];
cfg.channel = {'all' '-VEOG'};
data_clean = ft_selectdata(cfg, data_clean);
%this leaves 31 channels
    
% preprocess to obtain data format needed for ICA
cfg = [];
data_clean = ft_preprocessing(cfg, data_clean);

% perform the independent component analysis (i.e., decompose the data)
% ICA returns different components every time, so only do this when
% the data has changed since the last time
cfg        = [];
cfg.method = 'runica'; 
cfg.runica.pca = 30;
% berechnet pca, schmeißt kleinsten Komponenten weg und berechnet
% auf den übrigen ICA
% components auf 30 Komponenten rechnen (bipolare EOG raus, dann N-1)
comp = ft_componentanalysis(cfg, data_clean);

% visualization (I): topographies
% plot the components for visual inspection
figure
cfg = [];
cfg.component = 1:30;
cfg.layout = [dir_main 'Scripts' filesep 'layout.mat']; 
cfg.comment = 'no';
%cfg.style     = 'straight'; 
%cfg.gridscale = 300;
ft_topoplotIC(cfg, comp);

% visualization (II): time representation
% browse through components and trials
cfg = [];
cfg.layout = [dir_main 'Scripts' filesep 'layout.mat']; 
cfg.viewmode = 'component';
cfg.ylim = [-256 256];
cfg.verticalpadding = 0.1;
ft_databrowser(cfg, comp);

% remove the bad components and backproject the data
cfg = [];
cfg.component = [];
data_ica = ft_rejectcomponent(cfg, comp, data_clean);

%% averaging

