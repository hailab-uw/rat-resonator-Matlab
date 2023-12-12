threshold = .01;
color_thresh = [.01 .05];
sel_voxels_row = 63:64;
sel_voxels_col = 144:145;

% [matched_relative_1,alpha_1] = mask_BOLD(brain_masked,relative_1_t,threshold);
% [matched_relative_2,alpha_2] = mask_BOLD(brain_masked,relative_2_t,threshold);
% [matched_relative_3,alpha_3] = mask_BOLD(brain_masked,relative_3_t,threshold);
% [matched_relative_4,alpha_4] = mask_BOLD(brain_masked,relative_4_t,threshold);
% [matched_relative_5,alpha_5] = mask_BOLD(brain_masked,relative_5_t,threshold);
% 
% show_overlay(matched_relative_1,brain_masked,alpha_1,color_thresh);
% show_overlay(matched_relative_2,brain_masked,alpha_2,color_thresh);
% show_overlay(matched_relative_3,brain_masked,alpha_3,color_thresh);
% show_overlay(matched_relative_4,brain_masked,alpha_4,color_thresh);
% show_overlay(matched_relative_5,brain_masked,alpha_5,color_thresh);
% 
% avg_voxels_exp(5,1) = mean(matched_relative_1(sel_voxels_row,sel_voxels_col),"all");
% avg_voxels_exp(5,2) = mean(matched_relative_2(sel_voxels_row,sel_voxels_col),"all");
% avg_voxels_exp(5,3) = mean(matched_relative_3(sel_voxels_row,sel_voxels_col),"all");
% avg_voxels_exp(5,4) = mean(matched_relative_4(sel_voxels_row,sel_voxels_col),"all");
% avg_voxels_exp(5,5) = mean(matched_relative_5(sel_voxels_row,sel_voxels_col),"all");

relative_t = cat(3,relative_1_t,relative_2_t,relative_3_t,...
    relative_4_t,relative_5_t);
matched_relative_t = imresize(relative_t,...
    [size(t2_slice,1) size(t2_slice,2)]);
voxels_trace = squeeze(mean(matched_relative_t(sel_voxels_row,...
    sel_voxels_col,:),[1 2]));
figure
subplot(2,1,1)
plot(voxels_trace)
subplot(2,1,2)
time_smoothed_voxels = smooth(voxels_trace,20,'rlowess');
plot(time_smoothed_voxels)
xlim([225 375])

time_smoothed_relative_t = smoothdata(matched_relative_t,3,"lowess",20);
figure
subplot(length(sel_voxels_row),length(sel_voxels_col),1)
for idy= 1:length(sel_voxels_row)
    for idx = 1:length(sel_voxels_col)
        subplot(length(sel_voxels_row),length(sel_voxels_col),idx+((idy-1)*length(sel_voxels_col)))
        plot(squeeze(time_smoothed_relative_t(sel_voxels_row(idy),...
            sel_voxels_col(idx),:)))
        ylim([-.1 .1])
        xlim([225 375])
    end
end

[matched_smoothed_1,alpha_1] = mask_threshold(brain_masked,...
    time_smoothed_relative_t(:,:,276),threshold);
[matched_smoothed_2,alpha_2] = mask_threshold(brain_masked,...
    time_smoothed_relative_t(:,:,285),threshold);
[matched_smoothed_3,alpha_3] = mask_threshold(brain_masked,...
    time_smoothed_relative_t(:,:,293),threshold);
[matched_smoothed_4,alpha_4] = mask_threshold(brain_masked,...
    time_smoothed_relative_t(:,:,299),threshold);

show_overlay(matched_smoothed_1,brain_masked,alpha_1,color_thresh);
show_overlay(matched_smoothed_2,brain_masked,alpha_2,color_thresh);
show_overlay(matched_smoothed_3,brain_masked,alpha_3,color_thresh);
show_overlay(matched_smoothed_4,brain_masked,alpha_4,color_thresh);


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
    xlim(ax2,[75 175])
    ylim(ax2,[55 135])
    alpha(roi,alpha_map);
    clim(ax2,color_thresh)
end

function [matched_relative,alpha_map] = mask_threshold(maskedImage,relative_t,threshold)
    size_x = size(maskedImage,1);
    size_y = size(maskedImage,2);
    resized_relative = imresize(relative_t,[size_x size_y]);
    matched_relative = resized_relative;
    for idy = 1:size_y
        for idx = 1:size_x
            if maskedImage(idx,idy) == 0 || abs(resized_relative(idx,idy)) <= threshold
                matched_relative(idx,idy) = 0;
            end
        end
    end
    alpha_map = mat2gray(matched_relative);
end 

function [matched_relative,alpha_map] = mask_BOLD(maskedImage,relative,threshold)
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
    alpha_map = mat2gray(abs(matched_relative),[.02 .05]);
end