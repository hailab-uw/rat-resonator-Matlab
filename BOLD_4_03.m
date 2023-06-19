%start with clean slate (nobkpt)
clear       %no variables
close all   %no figures
clc         %empty command window

% Initialize Globals
upper_bound = 2600;
lower_bound = 800;
soi = 155:156; % slices of interest
test_row = 42:44;
test_col = 34:38;
control_col = 26:30;
row_size = 3;
col_size = 5;
baseline_frames = 5;

% Data Access
%----------------------------------------------------------------------

%filename convention used in image series (nobkpt)
prefix = 'D:\Data\2023_04_03_Suyash_Rat_Surgery_3_16\2023_04_03_Suyash_Rat_Surgery_3_16\2762_RS_Bold_2\1\2762_';
fnum = 00001:000500;
ext = '.dcm';

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

% Experimental & Control Group Percentage Change
baseline_test = double(zeros(row_size,col_size));
relative_test = double(zeros(row_size,col_size,size(D,3)));
avg_test  = double(zeros(1,size(D,3)));

baseline_control = double(zeros(row_size,col_size));
relative_control = double(zeros(row_size,col_size,size(D,3)));
avg_control  = double(zeros(1,size(D,3)));

for t = 1:baseline_frames
    baseline_test = baseline_test + double(D(test_row,test_col,t));
    baseline_control = baseline_control + ...
        double(D(test_row,control_col,t));
end
baseline_test = double(baseline_test/baseline_frames);
baseline_control = double(baseline_control/baseline_frames);

for t = baseline_frames+1:size(D,3)
    relative_control(:,:,t) = (double(D(test_row,control_col,t))-...
        baseline_control)./baseline_control;
    relative_test(:,:,t) = (double(D(test_row,test_col,t))-...
        baseline_test)./baseline_test;

    avg_control(t) = mean(relative_control(:,:,t),'all');
    avg_test(t) = mean(relative_test(:,:,t),'all');
end

% imtool(D(:,:,30),DisplayRange=[lower_bound upper_bound])
% 
% figure(1)
% plot(1:t,avg_test,1:t,avg_control)
% legend('Contralateral BOLD','Resonator BOLD')

bar(categorical({'Resonator % Change', 'Control % Change'}),...
    [rms(avg_test),rms(avg_control)])