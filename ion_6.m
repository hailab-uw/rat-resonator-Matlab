addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice_pre = get_t2('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3770_T2\1\3770_',14);
t2_slice = get_t2('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3789_post_T2\1\3789_',13);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3781_Bold_1\1\3781_',11:86);
rs_BOLD_t(:,:,1:500) = load_BOLD('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3776_RS_bold\1\3776_',1:500);
BOLD_t(:,:,1:500) = load_BOLD('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3781_Bold_1\1\3781_',1:500);
BOLD_t(:,:,501:1000) = load_BOLD('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3782_Bold_2\1\3782_',1:500);
BOLD_t(:,:,1001:1500) = load_BOLD('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3783_Bold_3\1\3783_',1:500);
BOLD_t(:,:,1501:2000) = load_BOLD('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3784_Bold_4\1\3784_',1:500);
BOLD_t(:,:,2001:2500) = load_BOLD('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3785_Bold_5\1\3785_',1:500);
BOLD_t(:,:,2501:3000) = load_BOLD('D:\Data\06_29_2023_Suyash_rat_surgery_04_18_injection\Suyash_rat_surgery_04_18_injection\3786_Bold_6\1\3786_',1:500);

baseline_rs_t = imresize(rs_BOLD_t(:,:,11:86),[size_rows size_cols]);
ion_rs_t = imresize(rs_BOLD_t,[size_rows size_cols]);

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
        sel_vec = squeeze(baseline_rs_t(y,x,:));
        pixel_filtered = filtfilt(ion_filt,double(sel_vec));
        baseline_rs_filtered(y,x,:) = pixel_filtered;

        sel_vec = squeeze(ion_rs_t(y,x,:));
        pixel_filtered = filtfilt(ion_filt,double(sel_vec));
        ion_rs_filtered(y,x,:) = pixel_filtered;

        sel_vec = squeeze(baseline_t_resized(y,x,:));
        pixel_filtered = filtfilt(ion_filt,double(sel_vec));
        baseline_t_filtered(y,x,:) = pixel_filtered;

        sel_vec = squeeze(ion_t_resized(y,x,:));
        pixel_filtered = filtfilt(ion_filt,double(sel_vec));
        ion_t_filtered(y,x,:) = pixel_filtered;
    end
end