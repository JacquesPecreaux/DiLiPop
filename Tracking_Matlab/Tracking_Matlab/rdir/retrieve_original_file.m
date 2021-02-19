function path = retrieve_original_file(originalFile, dest, annotationName)
    length_ = originalFile.getSize().getValue();
    global session;
    global param;
    if ~isempty(param) && isfield(param,'original_file_chunk') && ~isempty(param.original_file_chunk)
        inc = param.original_file_chunk;
    else
        inc = 262144;
    end
    
    rawFileStore = session.createRawFileStore();
    rawFileStore.setFileId(originalFile.getId().getValue());
 
    path = fullfile(dest,annotationName);
    [fid, message] = fopen(path,'w');
    if fid<=0
        error(message);
    end
    
    steps = 0:inc:(length_-1-inc);
    h = waitbar(0,'Downloading original file');
    if ~isempty(steps)
        for offset = steps
            data = int8(rawFileStore.read(offset, inc));      
            fwrite(fid,data,'int8');
            waitbar(offset/length_,h);
        end
    else
        offset = 0;
    end
    data = int8(rawFileStore.read(offset, length_-offset));      
    fwrite(fid,data,'int8');
    waitbar(1,h);
    
    rawFileStore.close();
    fclose_perso(fid);
    close(h);
end