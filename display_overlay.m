for row = 1:size(maskedImage,1)
    for col = 1:size(maskedImage,2)
        alpha_registered(row,col) = maskedImage(row,col) > 0 && abs(relative_t_6(row,col,180)) > 0.1;
    end
end

figure;
ax1 = axes;
imagesc(overlay);
colormap(ax1,'gray');
ax2 = axes;
imagesc(ax2,relative_t_6(:,:,180),'alphadata',alpha_registered);
colormap(ax2,'jet');
ax2.Visible = 'off';
linkprop([ax1 ax2],'Position');
clim([-1 1])