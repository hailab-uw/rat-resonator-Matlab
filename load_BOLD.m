function raw_BOLD = load_BOLD(path,fnum)

    ext='.dcm';
    for i=length(fnum):-1:1
        fname = [path sprintf('%05d',fnum(i)) ext];
        raw_BOLD(:,:,i) = uint16(dicomread(fname));
    end

end