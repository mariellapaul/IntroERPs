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

% limit to one subject to test
% subject = name_subj{2};

%%


for subj = (name_subj)
    % (re)set directory to the directory that contains the trialfun
    subject = subj{:};
    
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
% cfg = [];
% cfg.viewmode = 'vertical';
% ft_databrowser(cfg,data_raw);

% rereference to M2
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = {'M2'};
data_reref = ft_preprocessing(cfg, data_raw);

% % plot re-referenced data
% figure;
% plot(data_reref.time{1}, data_reref.trial{1}(:,:))
% cfg = [];
% cfg.viewmode = 'vertical';
% ft_databrowser(cfg,data_reref);


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
% 	data_hp_ex = ft_preprocessing(cfg, data_reref);
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
% 	data_lp_ex = ft_preprocessing(cfg, data_reref);
% 	figure;
% 	plot(data_lp.time{1}, data_lp.trial{1}(:,1))
% end

%% preprocessing (continued)

data_hp = data_reref;

% high-pass filter with the "final" options
% cfg = [];
% cfg.hpfilter = 'yes';
% cfg.hpfreq = 0.3;
% cfg.hpfiltdf = 0.3;
% cfg.hpfilttype = 'firws';
% cfg.hpfiltdir = 'onepass-zerophase';
% cfg.hpinstabilityfix = 'no';
% cfg.hpfiltwintype = 'kaiser';
% data_hp = ft_preprocessing(cfg, data_reref);
% % 
% % plot high-pass filtered data
% figure;
% plot(data_hp.time{1}, data_hp.trial{1}(:,:))


% low-pass filter with the "final" options
cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfilter = 30;
cfg.hpfilttype = 'firws';
cfg.hpfiltdir = 'onepass-zerophase';
cfg.hpinstabilityfix = 'no';
cfg.hpfiltdf = 5;
data_lp = ft_preprocessing(cfg, data_hp);

% % plot low-pass filtered data
% figure;
% plot(data_lp.time{1}, data_lp.trial{1}(:,:))

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
cfg.trialdef.eventvalue = {'S111', 'S112', 'S121', 'S122', 'S131',...
    'S132', 'S141', 'S142',... % standards
    'S2111', 'S2121', 'S2211', 'S2221,' 'S2311', 'S2321', 'S2411',...
    'S2421', ... % tone deviants
    'S2110', 'S2120', 'S2210', 'S2220', 'S2310', 'S2320', 'S2410',...
    'S2420'}; % vowel deviants
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
 
 save([dir_data subject filesep 'data_clean.mat'], 'data_clean');
 
end

%% ICA

for subj = (name_subj) 
    
subject = subj{:};

    
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

% browse trials again
cfg = [];
cfg.viewmode = 'vertical';
artf2 = ft_databrowser(cfg, data_ica);

 % artifact rejection: now the arifacts that were highlighted are removed
 % from the data
 cfg = [];
 cfg.artfctdef.reject = 'complete';
 % rejection of visual artifacts
 cfg.artfctdef.visual.artifact = artf2.artfctdef.visual.artifact;
 
 data_clean_ica = ft_rejectartifact(cfg, data_ica);
 
 save([dir_data subject filesep 'data_clean_ica.mat'], 'data_clean_ica');

save([dir_data subject filesep 'data_ica.mat'], 'data_ica');

end

for subj = (name_subj) 
%% averaging

subject = subj{:};


% make a directory, if needed, for this subject
if exist([dir_data subject], 'dir') == 0
        mkdir([dir_data subject]);
end
    
% baseline correction
cfg = [];
cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.2 0];
data_bc = ft_preprocessing(cfg, data_ica);

% make single subject averages for each condition
% standards
cfg = [];
cfg.trials = find(data_bc.trialinfo==111 | data_bc.trialinfo==112 | ...
     data_bc.trialinfo==121 | data_bc.trialinfo==122 | ...
     data_bc.trialinfo==131 | data_bc.trialinfo==132 | ...
     data_bc.trialinfo==141 | data_bc.trialinfo==142);
standards = ft_timelockanalysis(cfg, data_bc);
save([dir_data subject filesep 'avg_standards.mat'], 'standards');

% tone deviants
cfg = [];
cfg.trials = find(data_bc.trialinfo==2111 | data_bc.trialinfo==2121 | ...
     data_bc.trialinfo==2211 | data_bc.trialinfo==2221 | ...
     data_bc.trialinfo==2311 | data_bc.trialinfo==2321 | ...
     data_bc.trialinfo==2411 | data_bc.trialinfo==2421);
tonedev = ft_timelockanalysis(cfg, data_bc);
save([dir_data subject filesep 'avg_tonedev.mat'], 'tonedev');

% vowel deviants
cfg = [];
cfg.trials = find(data_bc.trialinfo==2110 | data_bc.trialinfo==2120 | ...
     data_bc.trialinfo==2210 | data_bc.trialinfo==2220 | ...
     data_bc.trialinfo==2310 | data_bc.trialinfo==2320 | ...
     data_bc.trialinfo==2410 | data_bc.trialinfo==2420);
voweldev = ft_timelockanalysis(cfg, data_bc);
save([dir_data subject filesep 'avg_voweldev.mat'], 'voweldev');


% plot single subject average
% cfg = [];
% cfg.layout = 'layout.mat';
% cfg.interactive = 'yes';
% cfg.showoutline = 'yes';
% ft_multiplotER(cfg, standards, tonedev, voweldev);

end

%% grand averages

filename = [dir_data 'Groupanalysis_ERP\GA_ERP.mat'];
 
if exist(filename, 'file')
    delete(filename);
end

cond_name = {'standards' 'tonedev' 'voweldev'};

% compute & save timelock grand average
cfg = [];
cfg.keepindividual = 'yes';
for i = 1:length(cond_name)
    condition = cond_name{i};
    GA = cell(1, length(name_subj));
   for s = 1:length(name_subj)
       subject = name_subj{s};
        data_in = load([dir_data subject filesep 'avg_' condition '.mat']);
        GA{s} = data_in.(condition);
    end
    GA_ERP.(condition) = ft_timelockgrandaverage(cfg, GA{:});
    
    if exist(filename, 'file')
        save(filename, '-struct', 'GA_ERP', condition, '-append');
    else
        save(filename, '-struct', 'GA_ERP', condition);
    end
    clear GA
end

%% plotting

GA_ERP = load([dir_data 'Groupanalysis_ERP\GA_erp.mat']);

% plot grand averages
cfg = [];
cfg.layout = 'layout.mat';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, standards, tonedev, voweldev);

%% Statistical analysis

% define neighbouring channels
cfg = [];
cfg.channel = {'all', '-M2', '-Fp2'};
cfg.method = 'triangulation';
cfg.layout = 'layout.mat';
cfg.feedback = 'yes'; % don't show a neighbour plot
neighbours = ft_prepare_neighbours(cfg, GA_ERP.standards); 

% prepare statistics

cfg = [];
cfg.channel = {'all', '-M2', '-Fp2'};
cfg.latency = [0 1];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT'; % within subjects design
cfg.correctm = 'cluster';
cfg.minnbchan = 2; % at least two adjacent channels to enter consideration
cfg.neighbours = neighbours; % as defined above
cfg.tail = 0; % two-tailed test
cfg.alpha = 0.025;
cfg.numrandomization = 1000;

% DESIGN CONFIG (for comparison of two conditions)
cfg.uvar  = 1;
cfg.ivar  = 2;
subjects = size(name_subj,2);
design = zeros(2,2*subjects);
design(1,:) = [1:subjects 1:subjects];
design(2,:) = [ones(1,subjects) 2*ones(1,subjects)];
cfg.design = design;

% run statistics: standards vs tone deviants
stat_tone = ft_timelockstatistics(cfg, GA_ERP.standards, GA_ERP.tonedev);
stat_vowel = ft_timelockstatistics(cfg, GA_ERP.standards, GA_ERP.voweldev);

% add 'avg' field to GA_ERP for plotting
cfg = [];
cfg.keepindividual = 'no';
cfg.parameter = 'individual';
for i = 1:length(cond_name)
    condition = cond_name{i};
    GA_ERP.(condition) = ft_timelockgrandaverage(cfg, GA_ERP.(condition));
end

% plot significant channels
significant_channels_ERP(GA_ERP.standards, GA_ERP.tonedev, stat_tone,...
    [dir_data 'Groupanalysis_ERP' filesep 'Significant_Clusters_ERP' ...
    filesep 'sta_vs_tonedev'], 'layout.mat')

significant_channels_ERP(GA_ERP.standards, GA_ERP.voweldev, stat_vowel,...
    [dir_data 'Groupanalysis_ERP' filesep 'Significant_Clusters_ERP' ...
    filesep 'sta_vs_voweldev'], 'layout.mat')


% output the pipeline
cfg = [];
cfg.filename = [dir_data 'pipeline'];
cfg.filetype = 'html';
output = ft_analysispipeline(cfg, GA_ERP.standards);
