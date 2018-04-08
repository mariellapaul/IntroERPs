% based on Antonia's TriggerUmbenennung.ods
% before this script works, the csv files have to be prepared:
% in TriggerUmbennung, there is one sheet per participant
% for all of these sheets:
% delete the following columns: A (empty), C ('all'), E ('User
% Properties'), F ('unchanged'), H (repetition of triggers; exists only
% sometimes)
% add a new column (E) filled with 0s
% save the sheet as lexa_0X.csv, with , as separator

clear variables;

% define variables with path names
dir_main = 'D:\Mind & Brain\EEG Kurs\';
dir_data = [dir_main 'EEG Daten Antonia\']; % 

% matrix with subject names
name_subj = struct2cell(dir(dir_data));
 % get names from eeg files
name_subj = name_subj(1,cellfun('isempty',strfind(name_subj(1,:),'.csv'))==0);
 % throw out '.csv', only leaves subject name
name_subj = regexprep(name_subj,'.csv','');

% limit to one subject to test
subject = name_subj{1};

for subj = (name_subj)
    
    subject = subj{:};

    % read csv (taken from Antonia's TriggerUmbenennung)
    csv = readtable([dir_data subject '.csv']);
    

    % make variable T that looks like the csv but also has 'MkX='
    for i = 1:length(csv.Var1)
        T.Var1{i,1} = strcat('Mk', num2str(i), '=', csv.Var1{i});
        T.Var2{i,1} = cell2mat(csv.Var2(i));
        T.Var3{i,1} = num2str(csv.Var3(i));
        T.Var4{i,1} = num2str(csv.Var4(i));
        T.Var5{i,1} = num2str(csv.Var5(i));
    end

    % write everything to a vmrk file, including the description at the
    % beginning of each vmrk file
    fid = fopen([dir_data subject '.vmrk'],'w');
    % print text at beginning of each file; insert subject as variable
    fprintf(fid, ['Brain Vision Data Exchange Marker File, Version 1.0\n\n' ...
        '[Common Infos]\nCodepage=UTF-8\nDataFile=%s.eeg\n\n' ...
        '[Marker Infos]\n; Each entry: Mk<Marker number>=<Type>,' ...
        '<Description>,<Position in data points>,\n' ...
        '; <Size in data points>, <Channel number (0 = marker ' ...
        'is related to all channels)>\n'...
        '; Fields are delimited by commas, some fields might be omitted ' ...
        '(empty).\n'...
        '; Commas in type or description text are coded as \"\\1\".\n'], ...
    subject);
    
    % insert markers (taken vom T variable that we made earlier)
    for i = 1:length(T.Var1)
        fprintf(fid,'%s,%s,%s,%s,%s\n', ...
            T.Var1{i}, T.Var2{i}, T.Var3{i}, T.Var4{i}, T.Var5{i});
    end
    fclose(fid);

end