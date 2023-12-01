resized_t = imresize(relative_seizure_t,[256 252]);

tiledlayout(4,6)
for row = 66:69
    for col = 141:146
        nexttile
        voxel = squeeze(resized_t(row,col,:));
        demodulated = demod(voxel,0.09,0.5/0.6);
        plot(t,demodulated)
        hold on
        plot(t,movmean(demodulated,20))
        hold off
        ylim([-0.5 0.5])
        xlim([500 1000])
        if row > 66 || col > 141
            axis off
        end
    end
end