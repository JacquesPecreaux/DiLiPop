function [STKplanes,STKplaneIndex,STKinfo,STKplaneInfo]=STKread_image(source,ind,STKplaneIndex,STKinfo,STKplaneInfo,Count)

    
    file = fopen (source, 'r');
    %read TIFF-header
    if (file==-1)
        error('Cannot open the file %s',source);
    end

    %read byte order first
    shortvalue = fread (file, 1, 'int16');

    if (shortvalue == hex2dec('4949'))
        endian='l';
    elseif (shortvalue == hex2dec('4D4D'))
        endian='b';
    % fclose (file);
    % error('File is in big endian order - no support yet');
    else
    fclose (file);
    error('No Stack File')
    end

    fclose (file);
    file = fopen (source, 'r',endian);


    stripsPerImage=Count;
    x=STKplaneInfo(1).ImageWidth;
    y=STKplaneInfo(1).ImageLength;
    STKplanes=uint16(zeros(y,x));
    if STKplaneInfo(1).BitsPerSample == 8
    s='uint8';
    elseif STKplaneInfo(1).BitsPerSample == 16
    s='uint16';
    else
    fclose (file);
    error('Only 8bit or 16bit Stacks supported');
    end 
    %h = waitbar(0,'Reading Stack - Please wait...'); 
    planeOffset = (ind-1) * (STKplaneInfo(1).StripOffsets(stripsPerImage) + STKplaneInfo(1).StripByteCounts(stripsPerImage) - STKplaneInfo(1).StripOffsets(1)) + STKplaneInfo(1).StripOffsets(1);
    fseek (file, planeOffset, 'bof');
    for k=1:y
    STKplanes(k,1:1:x) = fread(file,x,s,0,endian);
    end
    %waitbar(i/N)
    %close(h)
    fclose(file);
end
