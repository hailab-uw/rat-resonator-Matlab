% Initialize Globals
soi = 9:13; % slices of interest

% Data Access
%--------------------------------------------------------------------------

%filename convention used in image series (nobkpt)
prefix = 'D:\Data\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\2023_05_02_Suyash_Rat_Surgery_03_08_4ap\3158_t2\1\3158_';
fnum = 00001:22;
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
    flash(:,:,i) = uint16(dicomread(fname));
    waitbar((length(fnum)-i)/length(fnum))
end
delete(hWaitBar)
whos D

D_axial=flash;

sel_im = D_axial(:,:,14);

soi_thresholded = zeros(size(flash,3),size(flash,2),length(soi));


sel_im = imadjust(sel_im);
imtool(sel_im)

function new_img = threshold_image(img,lower_bound, upper_bound)
    new_img = zeros(size(img,1),size(img,2));
    for i = 1:size(img,1)
        for j = 1:size(img,2)
            if(img(i,j) > lower_bound) && (img(i,j) <= upper_bound)
                new_img(i,j) = img(i,j);
            end
        end
    end
end