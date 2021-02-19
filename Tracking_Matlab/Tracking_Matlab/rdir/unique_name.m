function [nom]=unique_name(stem,typ,double_check)
    if ~exist('double_check','var')
        double_check=0;
    end
%     typ='file' or typ='dir'
    function [nom]=name_build(index,path_)
        if strcmp(typ,'file')
                nom=fullfile(path_,sprintf('%s_%010d.ps',stem,index));
        elseif strcmp(typ,'dir')
            nom=fullfile(path_,sprintf('%s_%010d',stem,index));
        else
            nom=fullfile(path_,sprintf('%s_%010d.%s',stem,index,typ));
        end
    end

    function [res]=exist_helper(nom,typ_,double_check)
        res=exist(nom,typ_);
        if ~res && double_check
            pause(1);
            res=exist(nom,typ_);
        end
    end
    index=0;
    [path_,name_,ext_]=fileparts(stem);
    if isempty(path_)
        path_=pwd;
    end
    stem=[name_ ext_];
    nom=name_build(0,path_);
    
    while exist_helper(nom,'file',double_check)
        index=index+1;
        nom=name_build(index,path_);
    end
end
