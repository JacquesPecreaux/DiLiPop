function [result_,rev,date_rev]=Version_perso(p,toReporterLog)
    if nargin<2 || isempty(toReporterLog) || ~toReporterLog
        disp_perso=@disp;
    else
        disp_perso=@info_perso;
    end
    if isempty(p)
        disp('likely run in development environment - skipping versioning');
        result_='none - dev';
        date_rev = 'none - dev';
        rev = -1;
        return
    end
    if isdeployed
        if exist('Version_tag.txt','file')
            fp=fopen('Version_tag.txt','r');
            rev=fgetl(fp);
            result_=fscanf(fp,'%[^\1]\1');
            fclose(fp);
            disp_perso([datestr(now,'yyyy-mm-dd__HH-MM-SS') ' ---  DEPLOYED  ---']);
            disp_perso(result_);
        else
            disp_perso('No Version_tag.txt available');
            result_ = 'No Version_tag.txt available';
            date_rev='none';
            rev=-1;
            return;
        end
    else
        [pathstr, name]=fileparts(p);
        cur_dir=pwd;
        cd (pathstr);
        command='git --no-pager branch -v';
        [status, result]=unix(command);
        command='git --no-pager log -1';
        [status, result_]=unix(command);
        result=['  ---------' sprintf('\n') result '  ---------' sprintf('\n') result_ sprintf('\n') '  ---------'];
        [~,tags_]=unix('git --no-pager tag -l --points-at');
        disp_perso(datestr(now,'yyyy-mm-dd__HH-MM-SS'));
        disp_perso(result);
        if exist(cur_dir,'dir')
            cd(cur_dir);
        else
            warning_perso('We were in a non existent current dir, moving to home folder');
            cd(get_home);
        end
        k=strfind(result_,'commit');
        if ~isempty(k) && k(1)>=1 && k(1)<length(result_)
            result2=result_((k(1)+7):(k(1)+47));
            rev=sscanf(result2,'%s');
        else
            rev=-1;
        end
        rev=[rev ' ; ' strrep(tags_,sprintf('\n'),' ; ')];
        disp_perso(['--> Version: ' rev]);
    end

    k=strfind(result_,'Date:');
    if ~isempty(k) && k>=1 && k<length(result_)
        result2=result_((k+8):length(result_));
        k=strfind(result2,sprintf('\n'));
%         k2=strfind(result2,')');
        date_rev=result2(1:(k-1));
    else
        date_rev='none';
    end
    
end
