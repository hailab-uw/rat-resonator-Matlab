%start with clean slate (nobkpt)
clear       %no variables
close all   %no figures
clc         %empty command window

[baseline,tSNR_baseline] = baseline_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_1_(3_08_23)\2023_03_09_Suyash\2557_bold_fa20_400reps\1\2557_',1:50);
[relative_1,tSNR_1] = relative_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_1_(3_08_23)\2023_03_09_Suyash\2557_bold_fa20_400reps\1\2557_',50:400,baseline);
imtool(relative_1)

function [baseline,tSNR] = baseline_analyze(prefix,fnum)

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
    baseline = rms(double(D_baseline),3);

    std_baseline = std(double(D_baseline),0,3);
    tSNR = baseline./std_baseline;
end

function [relative,tSNR] = relative_analyze(prefix,fnum,baseline)
    %first filename in series (nobkpt)
    ext = '.dcm';
    fname = [prefix sprintf('%05d',fnum(1)) ext];
    
    %examine file header (nobkpt)
    info = dicominfo(fname);
    
    %extract size info from metadata (nobkpt)
    voxel_size = [info.PixelSpacing; info.SliceThickness]';
    
    %read slice images; populate XYZ matrix
    hWaitBar = waitbar(0,'Reading DICOM files');
    for i=length(fnum):-1:1
        fname = [prefix sprintf('%05d',fnum(i)) ext];
        D(:,:,i) = uint16(dicomread(fname));
        waitbar((length(fnum)-i)/length(fnum))
    end
    delete(hWaitBar)

    % -------------------------------------------------------------------------
    % fMRI Percentage Change
    avg = mean(double(D),3);

    relative_t = double(zeros(128,64,size(D,3)));

    for t = 1:size(fnum)
        relative_t(:,:,t) = (double(D(:,:,t))-...
            baseline)./baseline;
    end

    relative = rms(relative_t,3);
    std_relative = std(double(D),0,3);
    tSNR = avg./std_relative;
end