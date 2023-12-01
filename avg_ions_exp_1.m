threshold = .05;
color_thresh = [-.75 .4];
sel_voxels_row = 65:69;
sel_voxels_col = 146:150;

[matched_relative_1,alpha_1] = mask_BOLD(brain_masked,relative_1,threshold);
[matched_relative_2,alpha_2] = mask_BOLD(brain_masked,relative_2,threshold);
[matched_relative_3,alpha_3] = mask_BOLD(brain_masked,relative_3,threshold);
[matched_relative_4,alpha_4] = mask_BOLD(brain_masked,relative_4,threshold);
[matched_relative_5,alpha_5] = mask_BOLD(brain_masked,relative_5,threshold);
[matched_relative_6,alpha_6] = mask_BOLD(brain_masked,relative_6,threshold);

show_overlay(matched_relative_1,brain_masked,alpha_1,color_thresh);
show_overlay(matched_relative_2,brain_masked,alpha_2,color_thresh);
show_overlay(matched_relative_3,brain_masked,alpha_3,color_thresh);
show_overlay(matched_relative_4,brain_masked,alpha_4,color_thresh);
show_overlay(matched_relative_5,brain_masked,alpha_5,color_thresh);
show_overlay(matched_relative_6,brain_masked,alpha_6,color_thresh);

avg_voxels_ion(1,1) = mean(matched_relative_1(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(1,2) = mean(matched_relative_2(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(1,3) = mean(matched_relative_3(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(1,4) = mean(matched_relative_4(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(1,5) = mean(matched_relative_5(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ion(1,6) = mean(matched_relative_6(sel_voxels_row,sel_voxels_col),"all");

function show_overlay(masked_relative,anatomical,alpha_map,color_thresh)
    figure
    ax1 = axes;
    base = imagesc(anatomical);
    ax2 = axes;
    roi = imagesc(masked_relative);
    linkaxes([ax1,ax2]);
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    colormap(ax1,'gray');
    colormap(ax2,'jet');
    set(ax2,'color','none','visible','off');
    alpha(roi,alpha_map);
    clim(ax2,color_thresh)
end

function [matched_relative,alpha_map] = mask_BOLD(maskedImage,relative,threshold)
    size_x = size(maskedImage,2);
    size_y = size(maskedImage,1);
    resized_relative = imresize(relative,[size_y size_x]);
    matched_relative = resized_relative;
    alpha_map = ones(size_y,size_x);
    for idy = 1:size_y
        for idx = 1:size_x
            if maskedImage(idy,idx) == 0 || abs(resized_relative(idy,idx)) <= abs(threshold)
                matched_relative(idy,idx) = 0;
                alpha_map(idy,idx) = 0;
            end
        end
    end
end