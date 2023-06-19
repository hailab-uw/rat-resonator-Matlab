%start with clean slate (nobkpt)
clear       %no variables
close all   %no figures
clc         %empty command window

% Initialize Globals
upper_bound = 3000;
lower_bound = 1000;
soi = 155:156; % slices of interest
test_row = 35:37;
test_col = 33:38;
control_col = 26:31;
row_size = 3;
col_size = 6;

% Data Access
%----------------------------------------------------------------------

%filename convention used in image series (nobkpt)
prefix = 'D:\Data\2023_03_09_Suyash\2023_03_09_Suyash\2563_bold_fa5_50reps\1\2563_';
fnum = 00001:00050;
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

%67-72 x, 40-43 y. Divide x by 2. Contralateral 30-27
time_intensity = zeros(1,size(D,3));
for t = 1:size(D,3)
    pixel_intensity = 0;
    for r = test_row
        for c = test_col
            pixel_intensity = pixel_intensity + D(r,c,t);
        end
    end
    time_intensity(t) = pixel_intensity/(row_size*col_size);
end

control_intensity = zeros(1,size(D,3));
for t = 1:size(D,3)
    pixel_intensity = 0;
    for r = test_row
        for c = control_col
            pixel_intensity = pixel_intensity + D(r,c,t);
        end
    end
    control_intensity(t) = pixel_intensity/(row_size*col_size);
end

imtool(D(:,:,30),DisplayRange=[lower_bound upper_bound])

figure(1)
plot(1:t,control_intensity,1:t,time_intensity)
legend('Contralateral BOLD','Resonator BOLD')

control_amplitude = highpass(control_intensity,0.1,500/620);
time_amplitude = highpass(time_intensity,0.1,500/620);

figure(2)
plot(1:t,control_amplitude,1:t,time_amplitude)
legend('Contralateral BOLD','Resonator BOLD')
rms(control_amplitude)
rms(time_amplitude)

figure(3)
bar(categorical({'RMS Control Amplitude','RMS Resonator Amplitude'}),[rms(control_amplitude),rms(time_amplitude)])