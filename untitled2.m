%start with clean slate (nobkpt)
clear       %no variables
close all   %no figures
clc         %empty command window

%----------------------------------------------------------------------
% Initialize Globals
upper_bound = 2600;
lower_bound = 800;
soi = 155:156; % slices of interest
test_row = 36:38;
test_col = 35:37;
control_col = 27:29;
row_size = 3;
col_size = 3;
baseline_frames = 5;
adj_row = 36:45;
adj_col = 32:40;

D = read_BOLD('D:\Data\2023_04_03_Suyash_Rat_Surgery_3_16\2023_04_03_Suyash_Rat_Surgery_3_16\2762_RS_Bold_2\1\2762_',...
    1:500);
imtool(D(:,:,193))
[rms_test(4),rms_control(4)] = percentage_change(D,test_row,...
    test_col,control_col,baseline_frames);
[voxels,filtered_voxels] = adjacent_change(D,adj_row,adj_col,...
    baseline_frames);
figure
hold on
for row = 1:size(adj_row,2)
    for col = 1:size(adj_col,2)
        t = (1:size(D,3))+(1.2*col*size(D,3));
        extracted_vec = reshape(voxels(row,col,:),1,size(D,3));
        extracted_vec_filtered = reshape(filtered_voxels(row,col,:),1,size(D,3));
        % plot(t,extracted_vec+(4*(adj_size-idx)),'Color',"blue")
        plot(t,extracted_vec_filtered+(2*(size(adj_row,2)-row)),'Color',"red")
    end
end


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