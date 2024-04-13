addpath("GitHub\rat-resonator-Matlab\src\");

t2_slice = get_t2('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\2\4562_T2post\1\4562_',14);
size_cols = size(t2_slice,2);
size_rows = size(t2_slice,1);

baseline_t = load_BOLD('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\2\4556_bold1\1\4556_',11:86);
BOLD_t(:,:,1:500) = load_BOLD('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\2\4556_bold1\1\4556_',1:500);
BOLD_t(:,:,501:1000) = load_BOLD('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\2\4557_bold2\1\4557_',1:500);
BOLD_t(:,:,1001:1500) = load_BOLD('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\2\4558_bold3\1\4558_',1:500);
BOLD_t(:,:,1501:2000) = load_BOLD('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\2\4559_bold4\1\4559_',1:500);
BOLD_t(:,:,2001:2500) = load_BOLD('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\2\4560_bold5\1\4560_',1:500);
BOLD_t(:,:,2501:3000) = load_BOLD('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\2\4561_bold6\1\4561_',1:500);

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
ctrl_t(:,3) = squeeze(mean(ctrl_relative_t(58:60,134:136,:),[1 2]));