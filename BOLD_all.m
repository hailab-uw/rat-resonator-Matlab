%start with clean slate (nobkpt)
clear       %no variables
close all   %no figures
clc         %empty command window

% Initialize Globals
test_row = 42:44;
test_col = 33:37;
control_col = 27:31;
baseline_frames = 5;

D = read_BOLD('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_5_(4_10_23)\2023_04_12_Suyash_Rat_Surgery_4_10\2870_RS_Bold_27\1\2870_',...
    1:500);
[rms_test(1),rms_control(1)] = percentage_change(D,test_row,...
    test_col,control_col,baseline_frames);

%----------------------------------------------------------------------
% Initialize Globals
upper_bound = 2200;
lower_bound = 800;
soi = 155:156; % slices of interest
test_row = 33:37;
test_col = 37:40;
control_col = 26:29;
row_size = 5;
col_size = 4;
baseline_frames = 5;
adj_row = 36:51;
adj_col = 25:40;
adj_size = 16;


D = read_BOLD('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_1_(3_08_23)\2023_03_17_Suyash\2664_BOLD_RestingStatePart3_500reps\1\2664_',...
    1:500);
[rms_test(2),rms_control(2)] = percentage_change(D,test_row,...
    test_col,control_col,baseline_frames);

%----------------------------------------------------------------------
% Initialize Globals
upper_bound = 2200;
lower_bound = 800;
soi = 155:156; % slices of interest
test_row = 37:39;
test_col = 32:36;
control_col = 26:30;
baseline_frames = 5;
adj_row = 36:51;
adj_col = 25:40;
adj_size = 16;

D = read_BOLD('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_3_(3_27_23)\2023_03_27_Suyash\2733_RS_Bold_2\1\2733_',...
    1:500);
[rms_test(3),rms_control(3)] = percentage_change(D,test_row,...
    test_col,control_col,baseline_frames);

%----------------------------------------------------------------------
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
adj_row = 27:42;
adj_col = 32:47;
adj_size = 16;

D = read_BOLD('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_4_(3_16_23)\2023_04_03_Suyash_Rat_Surgery_3_16\2762_RS_Bold_2\1\2762_',...
    1:500);
[rms_test(4),rms_control(4)] = percentage_change(D,test_row,...
    test_col,control_col,baseline_frames);

%----------------------------------------------------------------------
% Initialize Globals
upper_bound = 2600;
lower_bound = 800;
soi = 155:156; % slices of interest
test_row = 32:34;
test_col = 32:35;
control_col = 28:31;
row_size = 3;
col_size = 4;
baseline_frames = 5;

D = read_BOLD('C:\Users\Suyash\Box\Suyash_MRI\Experimental_Group\Subj_2_(3_20_23)\2023_03_24_Suyash\2684_BOLD_RS_500reps1\1\2684_',...
    1:500);
[rms_test(5),rms_control(5)] = percentage_change(D,test_row,...
    test_col,control_col,baseline_frames);

%----------------------------------------------------------------------

figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[rms_test(1),rms_control(1)])
ylim([0,.17])

figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[rms_test(2),rms_control(2)])
ylim([0,.12])

figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[rms_test(3),rms_control(3)])
ylim([0,.13])

figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[rms_test(4),rms_control(4)])
ylim([0,.105])

figure
bar(categorical({'Experimental RMS Percent Change',...
    'Control RMS Percent Change'}),[rms_test(5),rms_control(5)])
ylim([0,.18])

figure
bar(categorical({'Control RMS Percent Change',...
    'Experimental RMS Percent Change'}),[mean(rms_control) mean(rms_test)])
errlow = [0 0];
errhigh = [std( rms_control ) / sqrt( length( rms_control ))...
    std( rms_test ) / sqrt( length( rms_test ))];

hold on

er = errorbar(categorical({'Control RMS Percent Change',...
    'Experimental RMS Percent Change'}),[mean(rms_control) mean(rms_test)],errlow,errhigh);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

hold off

%----------------------------------------------------------------------
function D = read_BOLD(prefix,fnum)
    %first filename in series (nobkpt)
    fname = [prefix sprintf('%05d',fnum(1)) '.dcm'];
    
    %examine file header (nobkpt)
    info = dicominfo(fname);
    
    %extract size info from metadata (nobkpt)
    voxel_size = [info.PixelSpacing; info.SliceThickness]';
    
    %read slice images; populate XYZ matrix
    hWaitBar = waitbar(0,'Reading DICOM files');
    for i=length(fnum):-1:1
        fname = [prefix sprintf('%05d',fnum(i)) '.dcm'];
        D(:,:,i) = uint16(dicomread(fname));
        waitbar((length(fnum)-i)/length(fnum))
    end
    delete(hWaitBar)
    whos D
end

function [rms_test,rms_control]=percentage_change(D,test_row,...
    test_col,control_col,baseline_frames)

    row_size = size(test_row,2);
    col_size = size(test_col,2);

    % ---------------------------------------------------------------------
    % fMRI Percentage Change
    
    % Baseline
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
    
    % Percentage Change to Baseline
    for t = baseline_frames+1:size(D,3)
        relative_control(:,:,t) = (double(D(test_row,control_col,t))-...
            baseline_control)./baseline_control;
        relative_test(:,:,t) = (double(D(test_row,test_col,t))-...
            baseline_test)./baseline_test;
    
        avg_control(t) = mean(relative_control(:,:,t),'all');
        avg_test(t) = mean(relative_test(:,:,t),'all');
    end
    
    % imtool(D(:,:,30),DisplayRange=[lower_bound upper_bound])
    
    % figure(1)
    % plot(1:t,avg_test,1:t,avg_control)
    % legend('Contralateral BOLD','Resonator BOLD')
    
    rms_test = rms(avg_test);
    rms_control = rms(avg_control);
end

function [voxels,filtered_voxels]=adjacent_change(D,adj_row,...
    adj_col,baseline_frames)

    row_size = size(adj_row,2);
    col_size = size(adj_col,2);

    % ---------------------------------------------------------------------
    % fMRI Percentage Change
    
    % Baseline
    baseline = double(zeros(row_size,col_size));
    voxels = double(zeros(row_size,col_size,size(D,3)));
    filtered_voxels = double(zeros(row_size,col_size,size(D,3)));
        
    for t = 1:baseline_frames
        baseline = baseline + double(D(adj_row,adj_col,t));
    end
    baseline = double(baseline/baseline_frames);
    
    % Percentage Change to Baseline
    for t = baseline_frames+1:size(D,3)
        voxels(:,:,t) = (double(D(adj_row,adj_col,t))-...
            baseline)./baseline;
    end

   % Filter relative voxel signal
   for r = 1:row_size
       for c = 1:col_size
           filtered_voxels(r,c,:) = lowpass(reshape(voxels(r,c,:),1,...
               size(D,3)),0.2,500/620);
       end
   end
end