addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice = get_t2('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\2\4920_T2_post\1\4920_',14);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\2\4914_bold1\1\4914_',11:86);
BOLD_t(:,:,1:500) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\2\4914_bold1\1\4914_',1:500);
BOLD_t(:,:,501:1000) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\2\4915_bold2\1\4915_',1:500);
BOLD_t(:,:,1001:1500) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\2\4916_bold3\1\4916_',1:500);
BOLD_t(:,:,1501:2000) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\2\4917_bold4\1\4917_',1:500);
BOLD_t(:,:,2001:2500) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\2\4918_bold5\1\4918_',1:500);
BOLD_t(:,:,2501:3000) = load_BOLD('D:\Data\Control\2023_10_25_Suyash\2023_10_25_Suyash\2\4919_bold6\1\4919_',1:500);

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
ctrl_t(:,5) = squeeze(mean(ctrl_relative_t(64:66,147:149,:),[1 2]));