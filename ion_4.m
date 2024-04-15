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
ion_t_resized = imresize(BOLD_t,[size_rows size_cols]);

ion_filt = designfilt('lowpassfir', ...        % Response type
   'FilterOrder',25, ...            % Filter order
   'StopbandFrequency',.02, ...     % Frequency constraints
   'PassbandFrequency',.01, ...
   'DesignMethod','ls', ...         % Design method
   'SampleRate',.5/.6);               % Sample rate

for x = 1:size_cols
    for y=1:size_rows
        sel_vec = squeeze(baseline_t_resized(y,x,:));
        pixel_filtered = filtfilt(ion_filt,double(sel_vec));
        baseline_t_filtered(y,x,:) = pixel_filtered;

        sel_vec = squeeze(ion_t_resized(y,x,:));
        pixel_filtered = filtfilt(ion_filt,double(sel_vec));
        ion_t_filtered(y,x,:) = pixel_filtered;
    end
end

ion_t_full = ion_t_filtered./mean(baseline_t_filtered,3);
ion_t(:,4) = squeeze(mean(ion_t_full(72:74,140:142,:),[1 2]));
for i=1:6
    avg_ion(4,i) = mean(ion_t((i-1)*500+1:i*500,4));
end