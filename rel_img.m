%start with clean slate (nobkpt)
clear       %no variables
close all   %no figures
clc         %empty command window

test_row = 33:37;
test_col = 37:40;
control_col = 26:29;
[baseline,tSNR_baseline] = baseline_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3162_RS_bold_slice14\1\3162_',1:50);
[relative_308,relative,tSNR] = relative_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3162_RS_bold_slice14\1\3162_',51,500,baseline);
imtool(relative)
figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[mean(relative(test_row,test_col),'all'),mean(relative(test_row,control_col),'all')])

test_row = 42:44;
test_col = 33:37;
control_col = 27:31;
[baseline,tSNR_baseline] = baseline_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_5_(4_10_23)\2023_04_12_Suyash_Rat_Surgery_4_10\2870_RS_Bold_27\1\2870_',1:50);
[relative_412,relative,tSNR] = relative_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_5_(4_10_23)\2023_04_12_Suyash_Rat_Surgery_4_10\2870_RS_Bold_27\1\2870_',50,500,baseline);
imtool(relative)
figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[mean(relative(test_row,test_col),'all'),mean(relative(test_row,control_col),'all')])

test_row = 37:39;
test_col = 32:36;
control_col = 26:30;
[baseline,tSNR_baseline] = baseline_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_3_(3_27_23)\2023_03_27_Suyash\2733_RS_Bold_2\1\2733_',1:50);
[relative_327,relative,tSNR] = relative_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_3_(3_27_23)\2023_03_27_Suyash\2733_RS_Bold_2\1\2733_',50,500,baseline);
imtool(relative)
figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[mean(relative(test_row,test_col),'all'),mean(relative(test_row,control_col),'all')])

test_row = 42:44;
test_col = 34:38;
control_col = 26:30;
[baseline,tSNR_baseline] = baseline_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_4_(3_16_23)\2023_04_03_Suyash_Rat_Surgery_3_16\2762_RS_Bold_2\1\2762_',1:50);
[relative_403,relative,tSNR] = relative_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_4_(3_16_23)\2023_04_03_Suyash_Rat_Surgery_3_16\2762_RS_Bold_2\1\2762_',50,500,baseline);
imtool(relative)
figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[mean(relative(test_row,test_col),'all'),mean(relative(test_row,control_col),'all')])

test_row = 40:43;
test_col = 35:37;
control_col = 29:31;
[baseline,tSNR_baseline] = baseline_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_6_(4_18_23)\2023_04_26_Suyash_Rat_Surgery_04_18\3070_RS_Bold_Slice14\1\3070_',1:50);
[relative_426,relative,tSNR] = relative_analyze('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_6_(4_18_23)\2023_04_26_Suyash_Rat_Surgery_04_18\3070_RS_Bold_Slice14\1\3070_',50,500,baseline);
imtool(relative)
figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[mean(relative(test_row,test_col),'all'),mean(relative(test_row,control_col),'all')])

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
    baseline = mean(abs(double(D_baseline)),3);

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
        relative_t(:,:,t) = (abs(double(D(:,:,t)))-...
            baseline)./baseline;
    end

    relative = rms(relative_t,3);
    std_relative = std(double(D),0,3);
    tSNR = avg./std_relative;
end