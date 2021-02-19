function warning_perso(varargin)
    global error_instead;
    global within_warning_perso;
    within_warning_perso = true;
    try
        fid=fopen_perso(fullfile(get_working_dir,'reporter.log'),'a',1);
        ds=datestr(now,'yyyy-mm-dd__HH-MM-SS');
        if isempty(error_instead) || ~error_instead
            fprintf(fid,'%s : warning : %s\n',ds,strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t')));
        else
            fprintf(fid,'%s : error : %s\n',ds,strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t')));
        end
        fclose_perso(fid);
    catch e
        reporter(nan,e,mfilename);
        pause(20);
        try
            fid=fopen_perso(fullfile(get_working_dir,'reporter.log'),'a',1);
            if isempty(error_instead) || ~error_instead
                fprintf(fid,'%s : warning : %s\n',ds,strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t')));
            else
                fprintf(fid,'%s : error : %s\n',ds,strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t')));
            end
            fclose_perso(fid);
        catch e
            reporter(nan,e,mfilename);
            warning(sprintf('cannot reach reporter.log!\n pwd=%s',strrep(pwd,'\','\\')));
        end
    end
    if isempty(error_instead) || ~error_instead
        disp(['Warning time stamp: ' ds]); 
        warning(varargin{:});
    else
        disp(['Error time stamp: ' ds]); 
        error_instead=0; % to ease debugging
        error(varargin{:});
    end    
    within_warning_perso = false;
end
