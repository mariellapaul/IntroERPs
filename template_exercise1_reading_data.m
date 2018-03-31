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