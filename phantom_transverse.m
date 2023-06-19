phase_4 = analyze('D:\Data\2023_06_14_Suyash_Phantom\2023_06_14_Suyash_Phantom\3651_B0map_te1\2\3651_',...
    'D:\Data\2023_06_14_Suyash_Phantom\2023_06_14_Suyash_Phantom\3651_B0map_te1\3\3651_',1:64);

phase_5 = analyze('D:\Data\2023_06_14_Suyash_Phantom\2023_06_14_Suyash_Phantom\3652_B0map_te2\2\3652_',...
    'D:\Data\2023_06_14_Suyash_Phantom\2023_06_14_Suyash_Phantom\3652_B0map_te2\3\3652_',1:64);

phase_6 = analyze('D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3578_B0map_te3\2\3578_',...
    'D:\Data\2023_05_31_Suyash_rat_surgery_5_10\2023_05_31_Suyash_rat_surgery_5_10\3578_B0map_te3\3\3578_',1:64);

map = phase_5-phase_4;
map_img_1 = reshape(map(82,:,:),[64 64]);
map_img_2 = reshape(map(42,:,:),[64 64]);


other_map = phase_6-phase_5;
other_map_img = reshape(map(70,:,:),[64 64]);

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