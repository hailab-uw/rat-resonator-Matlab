addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice = get_t2('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3195_t2_post\1\3195_',14);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3189_bold_post1\1\3189_',11:86);
BOLD_t(:,:,1:500) = load_BOLD('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3189_bold_post1\1\3189_',1:500);
BOLD_t(:,:,501:1000) = load_BOLD('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3190_bold_post2\1\3190_',1:500);
BOLD_t(:,:,1001:1500) = load_BOLD('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3191_bold_post3\1\3191_',1:500);
BOLD_t(:,:,1501:2000) = load_BOLD('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3192_bold_post4\1\3192_',1:500);
BOLD_t(:,:,2001:2500) = load_BOLD('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3193_bold_post5\1\3193_',1:500);
BOLD_t(:,:,2501:3000) = load_BOLD('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3194_bold_post6\1\3194_',1:500);

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
ion_t(:,1) = squeeze(mean(ion_t_full(69:71,143:145,:),[1 2]));
for i=1:6
    avg_ion(1,i) = mean(ion_t((i-1)*500+1:i*500,1));
end