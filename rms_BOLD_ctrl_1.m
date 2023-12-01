threshold = .065;
color_thresh = [.05 .1];
sel_voxels_row = 64:66;
sel_voxels_col = 131:132;

[matched_relative_1,alpha_1] = mask_BOLD(brain_masked,relative_1_t,threshold,color_thresh);
[matched_relative_2,alpha_2] = mask_BOLD(brain_masked,relative_2_t,threshold,color_thresh);
[matched_relative_3,alpha_3] = mask_BOLD(brain_masked,relative_3_t,threshold,color_thresh);
[matched_relative_4,alpha_4] = mask_BOLD(brain_masked,relative_4_t,threshold,color_thresh);
[matched_relative_5,alpha_5] = mask_BOLD(brain_masked,relative_5_t,threshold,color_thresh);
[matched_relative_6,alpha_6] = mask_BOLD(brain_masked,relative_6_t,threshold,color_thresh);

show_overlay(matched_relative_1,brain_masked,alpha_1,color_thresh);
show_overlay(matched_relative_2,brain_masked,alpha_2,color_thresh);
show_overlay(matched_relative_3,brain_masked,alpha_3,color_thresh);
show_overlay(matched_relative_4,brain_masked,alpha_4,color_thresh);
show_overlay(matched_relative_5,brain_masked,alpha_5,color_thresh);
show_overlay(matched_relative_6,brain_masked,alpha_6,color_thresh);

avg_voxels_ctrl(1,1) = mean(matched_relative_1(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ctrl(1,2) = mean(matched_relative_2(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ctrl(1,3) = mean(matched_relative_3(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ctrl(1,4) = mean(matched_relative_4(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ctrl(1,5) = mean(matched_relative_5(sel_voxels_row,sel_voxels_col),"all");
avg_voxels_ctrl(1,6) = mean(matched_relative_6(sel_voxels_row,sel_voxels_col),"all");

relative_t = cat(3,relative_1_t,relative_2_t,relative_3_t,...
    relative_4_t,relative_5_t,relative_6_t);
matched_relative_t = imresize(relative_t,...
    [size(t2_slice,1) size(t2_slice,2)]);
voxels_trace = squeeze(mean(matched_relative_t(sel_voxels_row,...
    sel_voxels_col,:),[1 2]));
figure
subplot(2,1,1)
plot(voxels_trace)
subplot(2,1,2)
plot(smooth(voxels_trace,20,'rlowess'))

function show_overlay(masked_relative,anatomical,alpha_map,color_thresh)
    figure
    ax1 = axes;
    base = imagesc(anatomical);
    ax2 = axes;
    roi = imagesc(masked_relative);
    linkaxes([ax1,ax2]);
    ax2.Visible = 'off';
    %ax1.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    colormap(ax1,'gray');
    colormap(ax2,'jet');
    set(ax2,'color','none','visible','off');
    alpha(roi,alpha_map);
    clim(ax2,color_thresh)
    xlim([75 175])
    ylim([45 140])
end

function [matched_relative,alpha_map] = mask_BOLD(maskedImage,relative,threshold,color_thresh)
    relative_rms = rms(relative,3);
    size_x = size(maskedImage,1);
    size_y = size(maskedImage,2);
    resized_relative = imresize(relative_rms,[size_x size_y]);
    matched_relative = resized_relative;
    for idy = 1:size_y
        for idx = 1:size_x
            if maskedImage(idx,idy) == 0 || abs(resized_relative(idx,idy)) <= threshold
                matched_relative(idx,idy) = 0;
            end
        end
    end
    alpha_map = mat2gray(matched_relative,[0 .2]);
end