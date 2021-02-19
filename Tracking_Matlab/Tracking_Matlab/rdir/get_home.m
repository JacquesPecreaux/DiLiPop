function tmp=get_home
        import java.lang.*;
        tmp=char(System.getProperty('user.home')); % it fails the first time sometimes
        if isempty(tmp) || ~exist(tmp,'dir')
            disp('System.getProperty(''user.home'') empty, returning system home folder instead');
            if ~ispc
                [st,tmp]=system('echo $HOME');
            end
            if ispc || st~=0 || isempty(tmp) || ~exist(tmp,'dir')
                if ~ispc
                    disp('system home empty, returning matlab HOME instead');
                else
                    disp('system home not attempted on PC, returning matlab HOME instead');
                end
                tmp=userpath;
                if isempty(tmp) || ~exist(tmp,'dir')
                    tmp=tempdir;
                    disp(['system $HOME emptyor failed, returning a temporary dir: "' tmp '"']);
                end
            end
        end
end