rho = 1;

[baseline,tSNR_baseline] = baseline_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3166_Bold_post_1\1\3166_',11:86,rho);
[relative_1_t,relative_1,tSNR_1] = relative_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3166_Bold_post_1\1\3166_',11,500,baseline,rho);
[relative_2_t,relative_2,tSNR_2] = relative_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3167_Bold_post_2\1\3167_',11,500,baseline,rho);
[relative_3_t,relative_3,tSNR_3] = relative_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3168_Bold_post_3\1\3168_',11,500,baseline,rho);
[relative_4_t,relative_4,tSNR_4] = relative_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3169_Bold_post_4\1\3169_',11,500,baseline,rho);
[relative_5_t,relative_5,tSNR_5] = relative_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3170_Bold_post_5\1\3170_',11,500,baseline,rho);
[relative_6_t,relative_6,tSNR_6] = relative_analyze('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3173_Bold_post_6\1\3173_',11,500,baseline,rho);

t2_slice = get_t2('D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3174_t2_post\1\3174_',15);

function t2_slice = get_t2(prefix,num)
    ext='.dcm';

    fname = [prefix sprintf('%05d',num) ext];
    t2_slice = uint16(dicomread(fname));
end

function [baseline,tSNR] = baseline_analyze(prefix,fnum,rho)

    ext='.dcm';

    d = designfilt('lowpassfir', ...        % Response type
       'FilterOrder',25, ...            % Filter order
       'StopbandFrequency',.03, ...     % Frequency constraints
       'PassbandFrequency',.01, ...
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
        D_baseline(:,:,i) = imgaussfilt(D_baseline(:,:,i),rho);
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

function [relative_t,relative,tSNR] = relative_analyze(prefix,start_slice,end_slice,baseline,rho)
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
        D(:,:,i-start_slice+1) = imgaussfilt(D(:,:,i-start_slice+1),rho);
    end

    d = designfilt('bandpassfir', ...        % Response type
       'FilterOrder',25, ...            % Filter order
       'StopbandFrequency1',.01, ...     % Frequency constraints
       'PassbandFrequency1',.03, ...
       'StopbandFrequency2',.11,...
       'PassbandFrequency2',.1, ...
       'DesignMethod','ls', ...         % Design method
       'SampleRate',.5/.6);             % Sample rate

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