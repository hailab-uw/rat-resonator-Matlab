addpath("GitHub\rat-resonator-Matlab\src\");

for t = 1:size(baseline_t_filtered,3)
    baseline_t_masked(:,:,t) = mask_BOLD(BOLD_mask,baseline_t_filtered(:,:,t),...
        size_cols,size_rows);

end
baseline = mean(baseline_t_masked,3);

for t = 1:size(ion_t_filtered,3)
    ion_t_masked(:,:,t) = mask_BOLD(BOLD_mask,ion_t_filtered(:,:,t),...
        size_cols,size_rows);

    ion_t_relative(:,:,t) = ion_t_masked(:,:,t)./baseline;
end