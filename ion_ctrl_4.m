addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice = get_t2('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\1\4903_T2_post\1\4903_',15);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\1\4897_Bold_1\1\4897_',11:86);
BOLD_t(:,:,1:500) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\1\4897_Bold_1\1\4897_',1:500);
BOLD_t(:,:,501:1000) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\1\4898_Bold_2\1\4898_',1:500);
BOLD_t(:,:,1001:1500) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\1\4899_Bold_3\1\4899_',1:500);
BOLD_t(:,:,1501:2000) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\1\4900_Bold_4\1\4900_',1:500);
BOLD_t(:,:,2001:2500) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\1\4901_Bold_5\1\4901_',1:500);
BOLD_t(:,:,2501:3000) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\1\4902_Bold_6\1\4902_',1:500);

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

ctrl_relative_t = ion_t_filtered./mean(baseline_t_filtered,3);
ctrl_t(:,4) = squeeze(mean(ctrl_relative_t(82:84,146:148,:),[1 2]));
for i=1:6
    avg_ctrl(4,i) = mean(ctrl_t((i-1)*500+1:i*500,4));
end