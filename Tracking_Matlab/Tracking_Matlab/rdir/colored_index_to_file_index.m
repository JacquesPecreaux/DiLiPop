function [jj_]=colored_index_to_file_index(ii_,format)
    global param;
    jj_=ii_;
    if strcmp(format,'itif')
        jj_=param.channel_total*(ii_-1)+param.channel_interest;
    elseif isempty(strfind(format,'omero')) % for omero, it is handled in a different fashion
        warning('No conversion colored_index_to_file_index  -  format ids not itif');
    end
end