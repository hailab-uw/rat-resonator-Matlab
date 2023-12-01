[baseline_rms,baseline_mean] = baseline_analyze('D:\Data\Suyash_05_10_2023_Rat_Surgery_03_08\3237_RS_Bold\1\3237_',1:50,60);
[relative_t_1,relative_1] = relative_analyze('D:\Data\Suyash_05_10_2023_Rat_Surgery_03_08\3237_RS_Bold\1\3237_',51:500,baseline_rms,baseline_mean,540);

relative_b_resized = imresize(baseline_mean,[256 252]);
relative_1_resized = imresize(relative_1,[256 252]);

function [baseline_rms, baseline_mean] = baseline_analyze(prefix,fnum,duration)

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
    parfor row = 1:size(D_baseline,1)
        baseline_row = reshape(double(D_baseline(row,:,:)),[size(D_baseline,2),size(D_baseline,3)]);
        
        baseline_t(row,:,:) = baseline_row;
    end
    baseline_rms = rms(baseline_t,3);
    baseline_mean = mean(baseline_t,3);
end

function [relative_t,relative] = relative_analyze(prefix,fnum,baseline_rms,baseline_mean,duration)

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
    parfor row = 1:size(D,1)
        sel_row = reshape(double(D(row,:,:)),[size(D,2),size(D,3)]);
        relative_t(row,:,:) = sel_row;
    end

    for t=1:size(D,3)
        rms_t(:,:,t) = relative_t(:,:,t)./baseline_rms;
        relative_t(:,:,t) = relative_t(:,:,t)./baseline_mean;
    end
    relative = rms(rms_t,3);
    parfor t = 1:size(D,3)
        resized_t(:,:,t) = imresize(relative_t(:,:,t),[256 252]);
    end
    relative_t = resized_t;
end