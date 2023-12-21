function display_overlay(rows,cols,BOLD_t_timesmoothed)
    subplot(length(rows),length(cols),1)
    for r_sel = 1:length(rows)
        for c_sel = 1:length(cols)
            subplot(length(rows),length(cols),(r_sel-1)*length(cols)+c_sel)
            plot(squeeze(BOLD_t_timesmoothed(rows(r_sel),cols(c_sel),:)))
        end
    end
end