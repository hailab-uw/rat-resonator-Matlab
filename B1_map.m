S1 = double(B1_read('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3744_B1map\1\3744_',65:128));
S2 = double(B1_read('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3744_B1map\1\3744_',129:192));

rel_sig = mod(S2./(2*S1),1);
map = acosd(rel_sig);

sel_im = reshape(map(:,:,47),[128 64]);
S2_im = reshape(S2(:,:,47),[128 64]);

function D = B1_read(prefix,fnum)

    ext='.dcm';

    fname_baseline = [prefix sprintf('%05d',fnum(1)) ext];
    baseline_info = dicominfo(fname_baseline);
    voxel_size = [baseline_info.PixelSpacing; baseline_info.SliceThickness]';
    
    hWaitBar = waitbar(0,'Reading DICOM files');
    for i=length(fnum):-1:1
        fname_baseline = [prefix sprintf('%05d',fnum(i)) ext];
        D(:,:,i) = uint16(dicomread(fname_baseline));
        waitbar((length(fnum)-i)/length(fnum))
    end
    delete(hWaitBar)

end