threshold = -.15;
color_thresh = [-.9 0];
sel_voxels_row = 65:69;
sel_voxels_col = 146:150;

[matched_relative_1,alpha_1] = mask_BOLD(ion_masked,relative_1,threshold);
[matched_relative_2,alpha_2] = mask_BOLD(ion_masked,relative_2,threshold);
[matched_relative_3,alpha_3] = mask_BOLD(ion_masked,relative_3,threshold);
[matched_relative_4,alpha_4] = mask_BOLD(ion_masked,relative_4,threshold);
[matched_relative_5,alpha_5] = mask_BOLD(ion_masked,relative_5,threshold);
[matched_relative_6,alpha_6] = mask_BOLD(ion_masked,relative_6,threshold);

show_overlay(matched_relative_1,brain_masked,alpha_1,color_thresh);
show_overlay(matched_relative_2,brain_masked,alpha_2,color_thresh);
show_overlay(matched_relative_3,brain_masked,alpha_3,color_thresh);
show_overlay(matched_relative_4,brain_masked,alpha_4,color_thresh);
show_overlay(matched_relative_5,brain_masked,alpha_5,color_thresh);
show_overlay(matched_relative_6,brain_masked,alpha_6,color_thresh);

avg_voxels_ion(6,1) = mean(matched_relative_1(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(6,2) = mean(matched_relative_2(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(6,3) = mean(matched_relative_3(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(6,4) = mean(matched_relative_4(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(6,5) = mean(matched_relative_5(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(6,6) = mean(matched_relative_6(sel_voxels_row,sel_voxels_col),"all");

function show_overlay(masked_relative,anatomical,alpha_map,color_thresh)
    figure
    ax1 = axes;
    anatomical_rot = imrotate(anatomical,3);
    relative_rot = imrotate(masked_relative,3);
    alpha_rot = imrotate(alpha_map,3);
    base = imagesc(anatomical_rot);
    ax2 = axes;
    roi = imagesc(relative_rot);
    linkaxes([ax1,ax2]);
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    colormap(ax1,'gray');
    colormap(ax2,'jet');
    set(ax2,'color','none','visible','off');
    alpha(roi,alpha_rot);
    clim(ax2,color_thresh)
    ylim(ax2,[65 130])
    xlim(ax2,[95 175])
end

function [matched_relative,alpha_map] = mask_BOLD(maskedImage,relative,threshold)
    size_x = size(maskedImage,2);
    size_y = size(maskedImage,1);
    resized_relative = imresize(relative,[size_y size_x]);
    matched_relative = resized_relative;
    alpha_map = ones(size_y,size_x);
    for idy = 1:size_y
        for idx = 1:size_x
            if maskedImage(idy,idx) == 0 || resized_relative(idy,idx) > threshold
                matched_relative(idy,idx) = 0;
                alpha_map(idy,idx) = 0;
            end
        end
    end
end