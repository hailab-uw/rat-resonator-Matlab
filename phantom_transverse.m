phase_4 = analyze('D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\2023_05_15_Suyash_rat_surgery_05_10_23\3308_B0map_TE1\2\3308_',...
    'D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\2023_05_15_Suyash_rat_surgery_05_10_23\3308_B0map_TE1\3\3308_',1:64);

phase_5 = analyze('D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\2023_05_15_Suyash_rat_surgery_05_10_23\3309_B0map_TE2\2\3309_',...
    'D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\2023_05_15_Suyash_rat_surgery_05_10_23\3309_B0map_TE2\3\3309_',1:64);

phase_6 = analyze('D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\2023_05_15_Suyash_rat_surgery_05_10_23\3310_B0map_TE3\2\3310_',...
    'D:\Data\2023_05_15_Suyash_rat_surgery_05_10_23\2023_05_15_Suyash_rat_surgery_05_10_23\3310_B0map_TE3\3\3310_',1:64);

map = phase_5-phase_4;
map_img = reshape(map(71,:,:),[64 64]);

other_map = phase_6-phase_5;
other_map_img = reshape(map(71,:,:),[64 64]);

function phase_mat = analyze(real_prefix,imaginary_prefix,fnum)

    ext='.dcm';

    fname_real = [real_prefix sprintf('%05d',fnum(1)) ext];
    fname_imaginary = [imaginary_prefix sprintf('%05d',fnum(1)) ext];
    info = dicominfo(fname_real);
    voxel_size = [info.PixelSpacing; info.SliceThickness]';

    hWaitBar = waitbar(0,'Reading DICOM files');
    for i=length(fnum):-1:1
        fname_real = [real_prefix sprintf('%05d',fnum(i)) ext];
        D_real(:,:,i) = uint16(dicomread(fname_real));
        fname_imaginary = [imaginary_prefix sprintf('%05d',fnum(i)) ext];
        D_imaginary(:,:,i) = uint16(dicomread(fname_imaginary));
        waitbar((length(fnum)-i)/length(fnum))
    end
    delete(hWaitBar)

    % -------------------------------------------------------------------------
    % fMRI Percentage Change
    
    % Baseline
    phase_mat = atan2(double(D_imaginary),double(D_real));
end