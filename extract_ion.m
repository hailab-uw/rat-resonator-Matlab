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

for i=1:6
    avg_ion_relative(:,:,i) = mean(ion_t_relative(:,:,(i-1)*500+1:i*500),3);
    %imtool(squeeze(avg_ion_relative(:,:,i)))
end

for t = 1:6
    for row = 1:size(BOLD_mask,1)
        for col = 1:size(BOLD_mask,2)
            alpha_registered(row,col,t) = avg_ion_relative(row,col,t) < 0.75;
            alpha_registered(row,col,t) = 1;
        end
    end
end

% [avg_ion_tilted,alpha_tilted,anatomical_tilted] = ...
%     tilt(avg_ion_relative,alpha_registered,anatomical,7);

for t=1:6
    make_overlay(avg_ion_relative(:,:,t),alpha_registered(:,:,t),anatomical);
end

function make_overlay(avg_ion_relative_t,alpha_registered_t,anatomical)
    figure;
    ax1 = axes;
    imagesc(anatomical);
    colormap(ax1,'gray');
    xlim([90 175])
    ylim([60 120])
    ax2 = axes;
    imagesc(ax2,avg_ion_relative_t,'alphadata',alpha_registered_t);
    colormap(ax2,'jet');
    ax2.Visible = 'off';
    clim([0 1])
    xlim([90 175])
    ylim([60 120])
    linkprop([ax1 ax2],'Position');
end

function [avg_ion_tilted,alpha_tilted,anatomical_tilted] = ...
    tilt(avg_ion_relative,alpha_registered,anatomical,tilt_angle)

    for t=1:6
        avg_ion_tilted(:,:,t) = imrotate(avg_ion_relative(:,:,t),tilt_angle);
        alpha_tilted(:,:,t) = imrotate(alpha_registered(:,:,t),tilt_angle);
    end
    anatomical_tilted = imrotate(anatomical,tilt_angle);
end