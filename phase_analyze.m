phase_4 = analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\2023_05_16_Phantoms_Suyash 2\2023_05_16_Phantoms_Suyash\Phantom1_Flat\3322_Phantom1_B0_TE1\2\3322_',...
    'C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\2023_05_16_Phantoms_Suyash 2\2023_05_16_Phantoms_Suyash\Phantom1_Flat\3322_Phantom1_B0_TE1\3\3322_',1:64);

phase_5 = analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\2023_05_16_Phantoms_Suyash 2\2023_05_16_Phantoms_Suyash\Phantom1_Flat\3323_Phantom1_B0_TE2\2\3323_',...
    'C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\2023_05_16_Phantoms_Suyash 2\2023_05_16_Phantoms_Suyash\Phantom1_Flat\3323_Phantom1_B0_TE2\3\3323_',1:64);

phase_6 = analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\2023_05_16_Phantoms_Suyash 2\2023_05_16_Phantoms_Suyash\Phantom1_Flat\3324_Phantom1_B0_TE3\2\3324_',...
    'C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\2023_05_16_Phantoms_Suyash 2\2023_05_16_Phantoms_Suyash\Phantom1_Flat\3324_Phantom1_B0_TE3\3\3324_',1:64);

map = phase_5-phase_4;
map_img = reshape(map(75,:,:),[64 64]);

other_map = phase_6-phase_5;
other_map_img = reshape(map(75,:,:),[64 64]);

for i=1:64
    fname = ['C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\2023_05_16_Phantoms_Suyash 2\2023_05_16_Phantoms_Suyash\Phantom1_Flat\3322_Phantom1_B0_TE1\1\3322_' sprintf('%05d',i) '.dcm'];
    D(:,:,i) = dicomread(fname);
end

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