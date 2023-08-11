[baseline,tSNR_baseline] = baseline_analyze('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3189_bold_post1\1\3189_',1:50);
[relative_1_t,relative_1,tSNR_1] = relative_analyze('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3189_bold_post1\1\3189_',51,500,baseline);
[relative_2_t,relative_2,tSNR_2] = relative_analyze('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3190_bold_post2\1\3190_',1,500,baseline);
[relative_3_t,relative_3,tSNR_3] = relative_analyze('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3191_bold_post3\1\3191_',1,500,baseline);
[relative_4_t,relative_4,tSNR_4] = relative_analyze('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3192_bold_post4\1\3192_',1,500,baseline);
[relative_5_t,relative_5,tSNR_5] = relative_analyze('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3193_bold_post5\1\3193_',1,500,baseline);
[relative_6_t,relative_6,tSNR_6] = relative_analyze('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3194_bold_post6\1\3194_',1,500,baseline);

t2_slice = get_t2('D:\Data\2023_05_03_Suyash_Rat_surgery_03_20_4ap\2023_05_03_Suyash_Rat_surgery_03_20_4ap\3195_t2_post\1\3195_',14);

function t2_slice = get_t2(prefix,num)
    ext='.dcm';

    fname = [prefix sprintf('%05d',num) ext];
    t2_slice = uint16(dicomread(fname));
end

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
    baseline = mean((double(D_baseline)),3);

    std_baseline = std(double(D_baseline),0,3);
    tSNR = baseline./std_baseline;
end

function [relative_t,relative,tSNR] = relative_analyze(prefix,start_slice,end_slice,baseline)
    %first filename in series (nobkpt)
    ext = '.dcm';
    fname = [prefix sprintf('%05d',start_slice) ext];
    
    %examine file header (nobkpt)
    info = dicominfo(fname);
    
    %extract size info from metadata (nobkpt)
    voxel_size = [info.PixelSpacing; info.SliceThickness]';
    
    %read slice images; populate XYZ matrix
    for i=end_slice:-1:start_slice
        fname = [prefix sprintf('%05d',i) ext];
        D(:,:,i-start_slice+1) = uint16(dicomread(fname));
    end

    % -------------------------------------------------------------------------
    % fMRI Percentage Change
    avg = mean(double(D),3);

    relative_t = double(zeros(128,64,size(D,3)));

    for t = 1:end_slice-start_slice+1
        relative_t(:,:,t) = ((double(D(:,:,t)))-...
            baseline)./baseline;
    end

    relative = mean(relative_t,3);
    std_relative = std(double(D),0,3);
    tSNR = avg./std_relative;
end