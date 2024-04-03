addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice = get_t2('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3174_t2_post\1\3174_',14);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3166_Bold_post_1\1\3166_',11:86);
BOLD_t(:,:,1:500) = load_BOLD('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3166_Bold_post_1\1\3166_',1:500);
BOLD_t(:,:,501:1000) = load_BOLD('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3167_Bold_post_2\1\3167_',1:500);
BOLD_t(:,:,1001:1500) = load_BOLD('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3168_Bold_post_3\1\3168_',1:500);
BOLD_t(:,:,1501:2000) = load_BOLD('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3169_Bold_post_4\1\3169_',1:500);
BOLD_t(:,:,2001:2500) = load_BOLD('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3170_Bold_post_5\1\3170_',1:500);
BOLD_t(:,:,2501:3000) = load_BOLD('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3173_Bold_post_6\1\3173_',1:500);

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