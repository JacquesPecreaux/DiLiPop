function info_perso(varargin)
 
    try
        disp(sprintf('%s : info : %s\n',datestr(now,'yyyy-mm-dd__HH-MM-SS'),strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t'))));
        fid=fopen_perso(fullfile(get_working_dir,'reporter.log'),'a',1);
        fprintf(fid,'%s : info : %s\n',datestr(now,'yyyy-mm-dd__HH-MM-SS'),strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t')));
%         disp('%s : info : %s\n',datestr(now,'yyyy-mm-dd__HH-MM-SS'),strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t')));
        fclose_perso(fid);
    catch e
        reporter(nan,e,mfilename);
        pause(20);
        try
            disp(sprintf('%s : info : %s\n',datestr(now,'yyyy-mm-dd__HH-MM-SS'),strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t'))));
            fid=fopen_perso(fullfile(get_working_dir,'reporter.log'),'a',1);
            fprintf(fid,'%s : info : %s\n',datestr(now,'yyyy-mm-dd__HH-MM-SS'),strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t')));
%             disp('%s : info : %s\n',datestr(now,'yyyy-mm-dd__HH-MM-SS'),strrep(sprintf(varargin{:}),sprintf('\n'),sprintf('\n\t')));
            fclose_perso(fid);
        catch ee
            reporter(nan,ee,mfilename);
            warning(sprintf('error in disp info or cannot reach reporter.log!\n pwd=%s',strrep(pwd,'\','\\')));
        end
    end

%     warning(varargin{:});
end
