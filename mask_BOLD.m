matched_relative_1 = mask_BOLD(maskedImage,relative_1);

function matched_relative = mask_BOLD(maskedImage,relative)
    size_x = size(maskedImage,1);
    size_y = size(maskedImage,2);
    resized_relative = imresize(relative,[size_x size_y]);
    matched_relative = resized_relative;
    for idy = 1:size_y
        for idx = 1:size_x
            if maskedImage(idx,idy) == 0
                matched_relative(idx,idy) = 0;
            end
        end
    end
end