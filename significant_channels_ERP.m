function significant_channels_ERP (cond1, cond2, stats, output_path, layout)


    %% COMPUTE DIFFERENCE BETWEEN CONDITIONS

    cfg  = [];
    cfg.operation = 'subtract';
    cfg.parameter = 'avg'; % for timelock data
    %cfg.parameter = 'powspctrm'; % for freq data
    cond1_vs_cond2 = ft_math(cfg, cond1, cond2);

    %% POSITIVE AND NEGATIVE CLUSTERS

    % set variables needed for plotting
    timestep = 0.05;		% timestep between time windows for each subplot (in seconds)
    sampling_rate = 1 / (stats.time(2) - stats.time(1));	% temporal resolution (Hz)
    sample_count = length(stats.time); % number of temporal samples in the statistics object
    j = stats.time(1):timestep:stats.time(end);   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
    m = int32(1:timestep*sampling_rate:sample_count+1);  % temporal endpoints in EEG samples (indices)
    
    % only plot clusters that are significant; skip other clusters
    disp('Clusters')
    for identifier = {'posclusters', 'negclusters'}
        if isfield(stats, identifier{:}) && size(stats.(identifier{:}), 1) == 1
            cluster_pvals = [stats.(identifier{:})(:).prob];
            sig_clust_labels = find(cluster_pvals < stats.cfg.alpha);
            sig_clust = ismember(stats.([identifier{:} 'labelmat']), sig_clust_labels);
        else
            disp(['No ' identifier{:} ', SKIPPING.'])
            continue
        end
        
        if isempty(find(sig_clust, 1)) == 1
            disp(['No significant '  identifier{:} ' found, skipping']);
            continue
        end
        
        % plot one topoplot for each time window
        disp(['PLOTTING ' identifier{:}])
        fig = figure;
        
        for k = 1 : length(j)-1

            h = subplot(4,5,k); 
            
            cfg = [];  
            cfg.xlim = [j(k) j(k+1)];   % time interval of the subplot
            cfg.comment = 'xlim';   
            cfg.commentpos = 'title';   
            cfg.layout = layout;
            cfg.highlight = 'on';
            % only highlight electrodes that are part of a significant
            % cluster throughout the whole time window (alternative: any)
            interval = all(sig_clust(:, m(k):m(k+1)), 2);
            cfg.highlightchannel = find(interval);
            cfg.style = 'blank';
            ft_topoplotER(cfg, cond1_vs_cond2);% colorbar;
        
        %fig.PaperType = 'a4';
        saveas(fig, [output_path '_' identifier{:} '.png']);

        end % inner for loop (labels)
 
    end % outer for loop (poscluster / negclusters)
      
end % function

