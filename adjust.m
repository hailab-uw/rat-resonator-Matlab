[optimizer,metric] = imregconfig("monomodal");
adjusted = ...
    imregister(sel_im_post,sel_im,"similarity",optimizer,metric);
imtool(adjusted)
imtool(sel_im)