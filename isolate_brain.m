[matched_relative_1,alpha_1] = mask_BOLD(maskedImage,relative_1);
[matched_relative_2,alpha_2] = mask_BOLD(maskedImage,relative_2);
[matched_relative_3,alpha_3] = mask_BOLD(maskedImage,relative_3);
[matched_relative_4,alpha_4] = mask_BOLD(maskedImage,relative_4);
[matched_relative_5,alpha_5] = mask_BOLD(maskedImage,relative_5);
[matched_relative_6,alpha_6] = mask_BOLD(maskedImage,relative_6);

show_overlay(matched_relative_1,t2_slice,alpha_1);
show_overlay(matched_relative_2,t2_slice,alpha_2);
show_overlay(matched_relative_3,t2_slice,alpha_3);
show_overlay(matched_relative_4,t2_slice,alpha_4);
show_overlay(matched_relative_5,t2_slice,alpha_5);
show_overlay(matched_relative_6,t2_slice,alpha_6);

function show_overlay(masked_relative,anatomical,alpha_map)
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
    clim(ax2,[-.2 .2]);
    set(ax2,'color','none','visible','off');
    alpha(roi,alpha_map);
end

function [matched_relative,alpha_map] = mask_BOLD(maskedImage,relative)
    size_x = size(maskedImage,1);
    size_y = size(maskedImage,2);
    resized_relative = imresize(relative,[size_x size_y]);
    matched_relative = resized_relative;
    alpha_map = ones(size_x,size_y);
    for idy = 1:size_y
        for idx = 1:size_x
            if maskedImage(idx,idy) == 0 || abs(resized_relative(idx,idy)) <= .05
                matched_relative(idx,idy) = 0;
                alpha_map(idx,idy) = 0;
            end
        end
    end
end