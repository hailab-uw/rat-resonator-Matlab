addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice = get_t2('D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\3292_T2\1\3292_',14);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\3299_RS_bold_slice14\1\3299_',11:86);
BOLD_t = load_BOLD('D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\3299_RS_bold_slice14\1\3299_',1:500);
baseline_t_resized = imresize(baseline_t,[size_rows size_cols]);
BOLD_t_resized = imresize(BOLD_t,[size_rows size_cols]);

baseline_filt = designfilt('lowpassfir', ...        % Response type
   'FilterOrder',25, ...            % Filter order
   'StopbandFrequency',.03, ...     % Frequency constraints
   'PassbandFrequency',.01, ...
   'DesignMethod','ls', ...         % Design method
   'SampleRate',.5/.6);               % Sample rate

BOLD_filt = designfilt('bandpassfir', ...        % Response type
       'FilterOrder',25, ...            % Filter order
       'StopbandFrequency1',.01, ...     % Frequency constraints
       'PassbandFrequency1',.03, ...
       'StopbandFrequency2',.11,...
       'PassbandFrequency2',.1, ...
       'DesignMethod','ls', ...         % Design method
       'SampleRate',.5/.6);             % Sample rate

for x = 1:size_cols
    for y=1:size_rows
        sel_vec = squeeze(baseline_t_resized(y,x,:));
        pixel_filtered = filtfilt(baseline_filt,double(sel_vec));
        baseline_t_filtered(y,x,:) = pixel_filtered;
        sel_vec = squeeze(BOLD_t_resized(y,x,:));
        pixel_filtered = filtfilt(BOLD_filt,double(sel_vec));
        BOLD_t_filtered(y,x,:) = pixel_filtered;
    end
end