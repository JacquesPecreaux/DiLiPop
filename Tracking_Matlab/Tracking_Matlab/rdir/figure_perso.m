function [varargout]=figure_perso(varargin)
    global param;
    if isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java
        if nargout>0
                    varargout=cell(nargout,1);
        end
        return 
    end
    if nargin>=1
        varargout{:}=figure(varargin{:});
    else
        varargout{:}=figure;
    end
    if ~isempty(param) && isfield(param,'batch_mode') && ~isempty(param.batch_mode)  && param.batch_mode
%         set(varargout{1},'Visible','off');
    end
    ud=get(varargout{1},'UserData');
    if isempty(ud)
        ud=struct('figure_perso',true);
    else
        ud.figure_perso=true;
    end
    set(varargout{1},'UserData',ud);
end
    
