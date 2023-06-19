%start with clean slate (nobkpt)
clear       %no variables
close all   %no figures
clc         %empty command window

% Initialize Globals
soi = 155:156; % slices of interest
test_row = 32:34;
test_col = 35:38;
control_col = 27:30;
row_size = 3;
col_size = 4;
baseline_frames = 500;

% Data Access
%----------------------------------------------------------------------

%filename convention used in image series (nobkpt)
baseline_prefix = 'D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3162_RS_bold_slice14\1\3162_';
prefix = 'D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3168_Bold_post_3\1\3168_';
fnum = 00001:500;
ext = '.dcm';

%first filename in series (nobkpt)
fname_baseline = [baseline_prefix sprintf('%05d',fnum(1)) ext];

%examine file header (nobkpt)
baseline_info = dicominfo(fname_baseline);

%extract size info from metadata (nobkpt)
voxel_size = [baseline_info.PixelSpacing; baseline_info.SliceThickness]';

%read slice images; populate XYZ matrix
hWaitBar = waitbar(0,'Reading DICOM files');
for i=length(fnum):-1:1
    fname_baseline = [baseline_prefix sprintf('%05d',fnum(i)) ext];
    D_baseline(:,:,i) = uint16(dicomread(fname_baseline));
    waitbar((length(fnum)-i)/length(fnum))
end
delete(hWaitBar)
whos D

%first filename in series (nobkpt)
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
whos D

% -------------------------------------------------------------------------
% fMRI Percentage Change

% Baseline
baseline = double(zeros(128,64));
relative = double(zeros(128,64,size(D,3)));

for t = 1:baseline_frames
    baseline = baseline + double(D_baseline(:,:,t));
end
baseline = double(baseline/baseline_frames);

% Percentage Change to Baseline
for t = 1:baseline_frames
    relative(:,:,t) = (double(D(:,:,t))-...
        baseline)./baseline;
end

for row = 1:128
    for col = 1:64
        aggregate(row,col) = rms(relative(row,col,:));
    end
end

resized = imresize(aggregate,[256 252]);
for row = 1:256
    for col = 1:252
        alpha(row,col) = (resized(row,col) > 0.2);
    end
end

mean_seizure = mean(double(D),3);
std_seizure = std(double(D),0,3);
tSNR_seizure = mean_seizure./std_seizure;
imtool(tSNR_seizure)

mean_baseline = mean(double(D_baseline),3);
std_baseline = std(double(D_baseline),0,3);
tSNR_baseline = mean_baseline./std_baseline;
imtool(tSNR_baseline)

tSNR_change = (tSNR_seizure-tSNR_baseline)./tSNR_baseline;
imtool(tSNR_change)
