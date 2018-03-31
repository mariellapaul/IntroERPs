clear variables;

% define variables with path names
dir_main = 'C:\Users\Mariella\Desktop\Mind & Brain\EEG Kurs\';
dir_data = [dir_main 'Data\']; % 
% assure fieldtrip is in path
addpath('C:\Users\Mariella\Desktop\Crossing Borders\fieldtrip-20170105');
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

%% PREPROCESSING

% read data in
cfg = [];
cfg.dataset = [dir_data subject '.vhdr'];
data_raw = ft_preprocessing(cfg);

% plot raw data
% plot(data_raw.time{1}, data_raw.trial{1}(:,:))

% rereference to linked mastoids
% REF is the electrode on the left mastoid, the online reference
% RM is the electrode on the right mastoid
cfg = [];
cfg.reref = 'yes';
cfg.implicitref = 'REF';
cfg.refchannel = {'RM' 'REF'};
data_reref = ft_preprocessing(cfg, data_raw);

% % plot re-referenced data
% figure;
% plot(data_reref.time{1}, data_reref.trial{1}(:,:))

%% exercise

% % try different high-pass filters and plot the data
% cutoff_hp = [0.001 0.1 1 10];
% cfg = [];
% cfg.hpfilter = 'yes';
% for i = 1:length(cutoff_hp)
% 	cfg.hpfreq = cutoff_hp(i);
% 	data_hp = ft_preprocessing(cfg, data_reref);
% 	figure;
% 	plot(data_hp.time{1}, data_hp.trial{1}(:,:))
% end
% 
% % try different low-pass filters and plot the data
% cutoff_lp = [10 20 30 100];
% cfg = [];
% cfg.lpfilter = 'yes';
% for i = 1:length(cutoff_lp)
% 	cfg.lpfreq = cutoff_lp(i);
% 	data_lp = ft_preprocessing(cfg, data_reref);
% 	figure;
% 	plot(data_lp.time{1}, data_lp.trial{1}(:,1))
% end

%%

% high-pass filter with the "final" options
% cfg = [];
% cfg.hpfilter = 'yes';
% cfg.hpfreq = 0.1;
% data_hp = ft_preprocessing(cfg, data_raw);
% 
% % plot high-pass filtered data
% figure;
% plot(data_hp.time{1}, data_hp.trial{1}(:,:))


% low-pass filter with the "final" options
cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfilter = 70;
data_lp = ft_preprocessing(cfg, data_reref);

% plot low-pass filtered data
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
cfg.trialfun     = ['trialfun_affcog'];
cfg.headerfile   = headerfile;
cfg.datafile     = eegfile;
cfg_deftrial = ft_definetrial(cfg);
    
% apply trial definition to data
data_segmented = ft_redefinetrial(cfg_deftrial, data_lp);

%% ARTIFACT REJECTION

% muscle artifacts
cfg            = [];
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = 'all';
cfg.artfctdef.zvalue.cutoff      = 7;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.fltpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;
% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter    = 'yes';
cfg.artfctdef.zvalue.bpfreq      = [110 140];
cfg.artfctdef.zvalue.bpfiltord   = 9;
cfg.artfctdef.zvalue.bpfilttype  = 'but';
cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;
% make the process interactive
%cfg.artfctdef.zvalue.interactive = 'yes';
[cfg, artifact_muscle] = ft_artifact_zvalue(cfg, data_segmented);


% jump artifacts
cfg            = [];   
% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel    = 'all';
cfg.artfctdef.zvalue.cutoff     = 20;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0;
cfg.artfctdef.zvalue.fltpadding = 0;
% algorithmic parameters
cfg.artfctdef.zvalue.cumulative    = 'yes';
cfg.artfctdef.zvalue.medianfilter  = 'yes';
cfg.artfctdef.zvalue.medianfiltord = 9;
cfg.artfctdef.zvalue.absdiff       = 'yes';
% make the process interactive
%cfg.artfctdef.zvalue.interactive = 'yes';
[cfg, artifact_jump] = ft_artifact_zvalue(cfg, data_segmented);

% display data with artifacts highlighted
cfg = [];
cfg.channel = 'all';
cfg.viewmode = 'vertical';
cfg.ploteventlabels  = 'type=value';
%cfg.eegscale    = 0.4;
%cfg.mychanscale = 0.4;
%cfg.mychan    = {'H+' , 'H-', 'V+', 'V-'};
%checkall = ft_appenddata(cfg,data_final);
%cfg.ylim = [-50 50];
%cfg.channel = [1:15 17:28 32 33];
%cfg.event = data_nounonset_event;
cfg.artfctdef.muscle.artifact = artifact_muscle;
cfg.artfctdef.jump.artifact = artifact_jump;

artf=ft_databrowser(cfg,data_segmented);

 % artifact rejection: now the arifacts that were searched on the raw data
 % (muscle and jump) are removed from the epoched data
 cfg = [];
 cfg.artfctdef.reject = 'complete';
 % rejection of automatic muscle artifacts
 cfg.artfctdef.muscle.artifact = artf.artfctdef.muscle.artifact;
 % rejection of automatic jump artifacts
 cfg.artfctdef.jump.artifact = artf.artfctdef.jump.artifact;
 % rejection of visual artifacts
 cfg.artfctdef.visual.artifact = artf.artfctdef.visual.artifact;
 
 data_clean = ft_rejectartifact(cfg,data_segmented);
 
  % save cleaned data
%  save([dir_data 'data_clean'], 'data_clean');
 


%% ICA


