[baseline,tSNR_baseline] = baseline_analyze('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3738_Bold_post1\1\3738_',1:50);
[relative_1_t,relative_1,tSNR_1] = relative_analyze('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3738_Bold_post1\1\3738_',51,500,baseline);
[relative_2_t,relative_2,tSNR_2] = relative_analyze('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3739_Bold_post2\1\3739_',1,500,baseline);
[relative_3_t,relative_3,tSNR_3] = relative_analyze('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3740_Bold_post3\1\3740_',1,500,baseline);
[relative_4_t,relative_4,tSNR_4] = relative_analyze('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3741_Bold_post4\1\3741_',1,500,baseline);
[relative_5_t,relative_5,tSNR_5] = relative_analyze('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3742_Bold_post5\1\3742_',1,500,baseline);
[relative_6_t,relative_6,tSNR_6] = relative_analyze('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3743_Bold_post6\1\3743_',1,500,baseline);

t2_slice = get_t2('D:\Data\2023_06_21_Suyash_Rat_surg_4_10_injections\2023_06_21_Suyash_Rat_surg_4_10_injections\3749_T2post\1\3749_',15);

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