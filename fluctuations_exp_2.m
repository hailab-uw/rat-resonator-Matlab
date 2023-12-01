sel_voxels_row = 69:72;
sel_voxels_col = 119:121;

relative_t = cat(3,relative_1_t,relative_2_t,relative_3_t,relative_4_t,...
    relative_5_t,relative_6_t);

matched_relative_t = imresize(relative_t,...
    [size(t2_slice,1) size(t2_slice,2)]);

sel_voxels_avg = squeeze(...
    mean(matched_relative_t(sel_voxels_row,sel_voxels_col,:),[1 2]));

figure
plot(sel_voxels_avg)
% for d = 1:6
%     rms_relative(:,:,d) = squeeze(rms(matched_relative_t(:,:,(d-1)*10+1:d*10-1),3));
%     imtool(squeeze(rms_relative(:,:,d)))
% end