sel_voxels_row = 56:59;
sel_voxels_col = 128:136;

relative_t = cat(3,relative_1_t,relative_2_t,relative_3_t,relative_4_t,...
    relative_5_t,relative_6_t);

matched_relative_t = imresize(relative_t,...
    [size(t2_slice,1) size(t2_slice,2)]);

sel_voxels_avg = squeeze(...
    mean(matched_relative_t(sel_voxels_row,sel_voxels_col,:),[1 2]));

plot(sel_voxels_avg)
smoothed = smoothdata(sel_voxels_avg,"sgolay",20);
figure
plot(smoothed)