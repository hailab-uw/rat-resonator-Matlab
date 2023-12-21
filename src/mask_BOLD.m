function BOLD_t_masked = mask_BOLD(BOLD_mask,BOLD_t,size_cols,size_rows)
    for x = 1:size_cols
        for y = 1:size_rows
            if BOLD_mask(y,x) > 0
                BOLD_t_masked(y,x,:) = BOLD_t(y,x,:);
            else
                BOLD_t_masked(y,x,:) = 0;
            end
        end
    end
end