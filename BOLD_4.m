addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice = get_t2('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3589_T2post_stoppedearly\1\3589_',13);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3583_bold1\1\3583_',11:86);
BOLD_t(:,:,1:500) = load_BOLD('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3583_bold1\1\3583_',1:500);
BOLD_t(:,:,501:1000) = load_BOLD('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3584_bold2\1\3584_',1:500);
BOLD_t(:,:,1001:1500) = load_BOLD('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3585_bold3\1\3585_',1:500);
BOLD_t(:,:,1501:2000) = load_BOLD('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3586_bold4\1\3586_',1:500);
BOLD_t(:,:,2001:2500) = load_BOLD('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3587_bold5\1\3587_',1:500);
BOLD_t(:,:,2501:3000) = load_BOLD('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3588_bold6\1\3588_',1:500);

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
       'StopbandFrequency2',.15,...
       'PassbandFrequency2',.14, ...
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