addpath("GitHub\rat-resonator-Matlab\src\");
rho = 1.5;

for t = 1:size(baseline_t_filtered,3)
    baseline_t_masked(:,:,t) = mask_BOLD(BOLD_mask,baseline_t_filtered(:,:,t),...
        size_cols,size_rows);

    baseline_t_smoothed(:,:,t) = imgaussfilt(baseline_t_masked(:,:,t),rho);
end
baseline_smoothed = mean(baseline_t_smoothed,3);
baseline_masked = mean(baseline_t_masked,3);

for t = 1:size(BOLD_t_filtered,3)
    BOLD_t_masked(:,:,t) = mask_BOLD(BOLD_mask,BOLD_t_filtered(:,:,t),...
        size_cols,size_rows);

    BOLD_t_smoothed(:,:,t) = imgaussfilt(BOLD_t_masked(:,:,t),rho);
    BOLD_t_relative_smoothed(:,:,t) = BOLD_t_smoothed(:,:,t)./baseline_smoothed;
    BOLD_t_relative(:,:,t) = BOLD_t_masked(:,:,t)./baseline_masked;
end

BOLD_t_timesmoothed = smoothdata(BOLD_t_relative_smoothed,3,"lowess",20);

for i=1:6
    BOLD_relative_rms(:,:,i) = rms(BOLD_t_relative(:,:,((i-1)*500+1):i*500),3);
    BOLD_timesmoothed_rms(:,:,i) = rms(BOLD_t_timesmoothed(:,:,((i-1)*500+1):i*500),3);
end

for t = 1
    for row = 1:size(BOLD_mask,1)
        for col = 1:size(BOLD_mask,2)
            alpha_registered(row,col,t) = (BOLD_timesmoothed_rms(row,col,t) >.02)*.3;
        end
    end
end

for t=1:6
    make_overlay(BOLD_relative_rms(:,:,t),alpha_registered(:,:,t),anatomical);
end

function make_overlay(BOLD_rms,alpha_registered_t,anatomical)
    figure;
    ax1 = axes;
    imagesc(anatomical);
    colormap(ax1,'gray');
    ax2 = axes;
    imagesc(ax2,BOLD_rms,'alphadata',alpha_registered_t);
    colormap(ax2,'jet');
    ax2.Visible = 'off';
    % clim([0.02 .07])
    linkprop([ax1 ax2],'Position');
end