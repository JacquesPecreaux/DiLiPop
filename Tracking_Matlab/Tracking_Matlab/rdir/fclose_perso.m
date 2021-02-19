function res = fclose_perso(arg)
    global within_warning_perso
    filename = [];
    if strcmp(arg,'all')
        warning_perso('fclose_perso is only supported with fid as argument, not "all". Proceeding as fclose only');
    else
        [filename,permission] = fopen(arg);
    end
    try
        res = fclose(arg);
    catch error_
        error_instead=1; %#ok<NASGU>
        e_txt=sprintf('I cannot close the file with FID "%d" (despite a positive fid)\nerror # %s : %s\n%s\n',arg,error_.identifier ,strrep(error_.message,sprintf('\n') ,sprintf('\n\t')) ,stack_text(error_.stack));
        warning_perso(e_txt);
    end
    if ~isempty(filename)
        if ~strcmp(permission,'r')
            if ~ispc
                status = ~system(['chmod g+w,o-wx ''' filename '''']); 
            else
                status = fileattrib(filename,'+w','u g') && fileattrib(filename,'-w -x','o');
            end
            if ~status
                if ~isempty(within_warning_perso) && within_warning_perso
                    warning('Failed to set permissions for file "%s"',filename);
                else
                    warning_perso('Failed to set permissions for file "%s"',filename);
                end
            end
        end
    end
end