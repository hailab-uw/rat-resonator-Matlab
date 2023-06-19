baseline = baseline_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3162_RS_bold_slice14\1\3162_',1:500,600);
[relative_t,relative] = relative_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3162_RS_bold_slice14\1\3162_',1:500,baseline,600);
imtool(relative)

function baseline = baseline_analyze(prefix,fnum,duration)

    fs = double(length(fnum))/duration;
    ext='.dcm';

    fname_baseline = [prefix sprintf('%05d',fnum(1)) ext];
    baseline_info = dicominfo(fname_baseline);
    voxel_size = [baseline_info.PixelSpacing; baseline_info.SliceThickness]';
    
    hWaitBar = waitbar(0,'Reading DICOM files');
    for i=length(fnum):-1:1
        fname_baseline = [prefix sprintf('%05d',fnum(i)) ext];
        D_baseline(:,:,i) = uint16(dicomread(fname_baseline));
        waitbar((length(fnum)-i)/length(fnum))
    end
    delete(hWaitBar)

    % -------------------------------------------------------------------------
    % fMRI Percentage Change
    
    % Baseline
    for row = 1:size(D_baseline,1)
        for col = 1:size(D_baseline,2)
            baseline_voxel = reshape(double(D_baseline(row,col,:)),[1,size(D_baseline,3)]);
            
            baseline_t(row,col,:) = lowpass(baseline_voxel,0.1,fs);
        end
    end
    baseline = rms(baseline_t,3);
end

function [relative_t,relative] = relative_analyze(prefix,fnum,baseline,duration)

    fs = double(length(fnum)/duration);
    %first filename in series (nobkpt)
    ext = '.dcm';
    fname = [prefix sprintf('%05d',fnum(1)) ext];
    
    %examine file header (nobkpt)
    info = dicominfo(fname);
    
    %extract size info from metadata (nobkpt)
    voxel_size = [info.PixelSpacing; info.SliceThickness]';
    
    %read slice images; populate XYZ matrix
    for i=1:length(fnum)
        fname = [prefix sprintf('%05d',fnum(i)) ext];
        D(:,:,i) = uint16(dicomread(fname));
    end

    % -------------------------------------------------------------------------
    % fMRI Percentage Change
    for row = 1:size(D,1)
        for col = 1:size(D,2)
            sel_voxel = reshape(double(D(row,col,:)),[1,size(D,3)]);
            filtered_voxel = highpass(sel_voxel,0.1,fs);
            relative_t(row,col,:) = filtered_voxel./baseline(row,col);
        end
    end

    relative = rms(relative_t,3);
end