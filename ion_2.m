addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice = get_t2('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3749_T2post\1\3749_',15);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3738_Bold_post1\1\3738_',11:86);
BOLD_t(:,:,1:500) = load_BOLD('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3738_Bold_post1\1\3738_',1:500);
BOLD_t(:,:,501:1000) = load_BOLD('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3739_Bold_post2\1\3739_',1:500);
BOLD_t(:,:,1001:1500) = load_BOLD('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3740_Bold_post3\1\3740_',1:500);
BOLD_t(:,:,1501:2000) = load_BOLD('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3741_Bold_post4\1\3741_',1:500);
BOLD_t(:,:,2001:2500) = load_BOLD('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3742_Bold_post5\1\3742_',1:500);
BOLD_t(:,:,2501:3000) = load_BOLD('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3743_Bold_post6\1\3743_',1:500);

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
ion_t(:,2) = squeeze(mean(ion_t_full(70:72,124:126,:),[1 2]));
for i=1:6
    avg_ion(2,i) = mean(ion_t((i-1)*500+1:i*500,2));
end