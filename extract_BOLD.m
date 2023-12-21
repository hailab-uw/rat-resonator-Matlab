addpath("GitHub\rat-resonator-Matlab\src\");
rho = 1.5;

for t = 1:size(baseline_t_filtered,3)
    baseline_t_masked(:,:,t) = mask_BOLD(BOLD_mask,baseline_t_filtered(:,:,t),...
        size_cols,size_rows);

    baseline_t_smoothed(:,:,t) = imgaussfilt(baseline_t_masked(:,:,t),rho);
end
baseline = mean(baseline_t_smoothed,3);

for t = 1:size(BOLD_t_filtered,3)
    BOLD_t_masked(:,:,t) = mask_BOLD(BOLD_mask,BOLD_t_filtered(:,:,t),...
        size_cols,size_rows);

    BOLD_t_smoothed(:,:,t) = imgaussfilt(BOLD_t_masked(:,:,t),rho);
    BOLD_t_relative(:,:,t) = BOLD_t_smoothed(:,:,t)./baseline;
end

BOLD_t_timesmoothed = smoothdata(BOLD_t_relative,3,"lowess",20);