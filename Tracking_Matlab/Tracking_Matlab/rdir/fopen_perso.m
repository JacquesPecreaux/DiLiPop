function [fid,message]=fopen_perso(nom,flag,error_or_warning,param)
% global first_call_fopen_perso;
% if first_call_fopen_perso
%     p = mfilename('fullpath');
%     Version_perso(p);
%     first_call_fopen_perso=0;
% end
    if strcmp(nom((end-3):end),'.mat')
        if exist(nom,'file')
            fid = load(nom);
        else
            fid=-1;
            message = '(file does not exist)';
        end
    else
        if (nargin==3)
            [fid,message] = fopen(nom,flag);
        elseif (nargin==4)
            [fid,message] = fopen(nom,flag,param);
        else
            error('JACQ:BADNBARG','Bad number of arguments for fopen_perso');
        end
    end
    if (~isstruct(fid) && fid<=0)
        if error_or_warning
            error('JACQ:CANTOPEN','cannot open the file %s\n%s',nom,message);
        else
            info_perso('testing current and default tag : I will try a other naming scheme but right now I cannot open the file %s\n%s',nom,message);
        end
    end
end
