threshold = .085;
color_thresh = [.05 .38];

[matched_relative_1,alpha_1] = mask_BOLD(rms_masked,rep_sample_1,threshold);
[matched_relative_2,alpha_2] = mask_BOLD(rms_masked,rep_sample_2,threshold);
[matched_relative_3,alpha_3] = mask_BOLD(rms_masked,rep_sample_3,threshold);
[matched_relative_4,alpha_4] = mask_BOLD(rms_masked,rep_sample_4,threshold);
[matched_relative_5,alpha_5] = mask_BOLD(rms_masked,rep_sample_5,threshold);
[matched_relative_6,alpha_6] = mask_BOLD(rms_masked,rep_sample_6,threshold);

alpha_T2 = mask_T2(brain_masked);

show_overlay(matched_relative_1,brain_masked,alpha_1,alpha_T2,color_thresh);
show_overlay(matched_relative_2,brain_masked,alpha_2,alpha_T2,color_thresh);
show_overlay(matched_relative_3,brain_masked,alpha_3,alpha_T2,color_thresh);
show_overlay(matched_relative_4,brain_masked,alpha_4,alpha_T2,color_thresh);
show_overlay(matched_relative_5,brain_masked,alpha_5,alpha_T2,color_thresh);
show_overlay(matched_relative_6,brain_masked,alpha_6,alpha_T2,color_thresh);


function show_overlay(masked_relative,anatomical,alpha_BOLD,...
    alpha_T2,color_thresh)

    figure
    ax1 = axes;
    base = imagesc(anatomical);
    alpha(base, alpha_T2)
    ax2 = axes;
    roi = imagesc(masked_relative);
    linkaxes([ax1,ax2]);
    ax2.Visible = 'off';
    ax1.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    colormap(ax1,'gray');
    colormap(ax2,'jet');
    set(ax2,'color','none','visible','off');
    xlim(ax2,[80 165])
    ylim(ax2,[60 125])
    clim(ax2,color_thresh)
    alpha(roi,alpha_BOLD);
end

function alpha_T2 = mask_T2(anatomical)
    rows = size(anatomical,1);
    cols = size(anatomical,2);
    alpha_T2 = ones(rows,cols);

    for idy = 1:rows
        for idx = 1:cols
            if(anatomical(idy,idx) == 0)
                alpha_T2(idy,idx) = 1;
            end
        end
    end
end

function [matched_relative,alpha_BOLD] = mask_BOLD(maskedImage,relative,threshold)
    relative_rms = rms(relative,3);
    size_x = size(maskedImage,1);
    size_y = size(maskedImage,2);
    resized_relative = imresize(relative_rms,[size_x size_y]);
    matched_relative = resized_relative;
    for idy = 1:size_y
        for idx = 1:size_x
            if maskedImage(idx,idy) == 0
                matched_relative(idx,idy) = 0;
            elseif abs(resized_relative(idx,idy)) <= threshold
                matched_relative(idx,idy) = 0;
            end
        end
    end
    alpha_BOLD = mat2gray(matched_relative,[0 .3]);
end