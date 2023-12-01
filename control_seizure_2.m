[baseline,tSNR_baseline] = baseline_analyze('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\1\4539_bold1\1\4539_',11:86);
[relative_1_t,relative_1,tSNR_1] = relative_analyze('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\1\4539_bold1\1\4539_',11,500,baseline);
[relative_2_t,relative_2,tSNR_2] = relative_analyze('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\1\4540_bold2\1\4540_',11,500,baseline);
[relative_3_t,relative_3,tSNR_3] = relative_analyze('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\1\4541_bold3\1\4541_',11,500,baseline);
[relative_4_t,relative_4,tSNR_4] = relative_analyze('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\1\4542_bold4\1\4542_',11,500,baseline);
[relative_5_t,relative_5,tSNR_5] = relative_analyze('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\1\4543_bold5\1\4543_',11,500,baseline);
[relative_6_t,relative_6,tSNR_6] = relative_analyze('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\1\4544_bold6\1\4544_',11,500,baseline);

t2_slice = get_t2('D:\Data\Control\2023_10_12_Suyash\2023_10_12_Suyash\1\4545_T2post\1\4545_',14);



function t2_slice = get_t2(prefix,num)
    ext='.dcm';

    fname = [prefix sprintf('%05d',num) ext];
    t2_slice = uint16(dicomread(fname));
end

function [baseline,tSNR] = baseline_analyze(prefix,fnum)

    ext='.dcm';

    d = designfilt('lowpassfir', ...        % Response type
       'FilterOrder',25, ...            % Filter order
       'StopbandFrequency',.16, ...     % Frequency constraints
       'PassbandFrequency',.15, ...
       'DesignMethod','ls', ...         % Design method
       'SampleRate',.5/.6);               % Sample rate

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
    D_baseline = double(D_baseline);

    % Compensate for noise if needed
    for idy = 1:size(D_baseline,1)
        for idx = 1:64
            sel_vec = squeeze(D_baseline(idy,idx,:));
            filtered_pixel = filtfilt(d,sel_vec);
            D_filtered(idy,idx,:) = filtered_pixel;
        end
    end

    % Baseline
    baseline = mean((double(D_filtered)),3);

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

    d = designfilt('bandpassfir', ...        % Response type
       'FilterOrder',25, ...            % Filter order
       'StopbandFrequency1',.02, ...     % Frequency constraints
       'PassbandFrequency1',.03, ...
       'StopbandFrequency2',.16,...
       'PassbandFrequency2',.15, ...
       'DesignMethod','ls', ...         % Design method
       'SampleRate',.5/.6);               % Sample rate

    % -------------------------------------------------------------------------
    % fMRI Percentage Change
    avg = mean(double(D),3);

    relative_t = double(zeros(128,64,size(D,3)));
    D = double(D);

    for idy = 1:size(D,1)
        for idx = 1:64
            sel_vec = squeeze(D(idy,idx,:));
            filtered_pixel = filtfilt(d,sel_vec);
            D_filtered(idy,idx,:) = filtered_pixel;
        end
    end

    for t = 1:end_slice-start_slice+1
        relative_t(:,:,t) = double(D_filtered(:,:,t)) ...
            ./baseline(:,:);
    end

    % filtered_relative_t = filtfilt(d,permute(relative_t,[3 2 1]));
    % filtered_relative_t = permute(filtered_relative_t,[3 2 1]);
    % relative_t = filtered_relative_t;

    relative = mean(relative_t,3);
    std_relative = std(double(D),0,3);
    tSNR = avg./std_relative;
end