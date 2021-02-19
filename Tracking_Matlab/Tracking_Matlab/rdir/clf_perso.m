function varargout=clf_perso(varargin)
global param;
global general_param
    if isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java
        return 
    end
    if nargin>=1 && nargout>=1 && (isempty(varargin{1}) || ~ishandle(varargin{1}))
        varargout{1}=figure_perso;
        warning_perso('clf_perso created that figure as it was called with an empty or invalid figure handle');
        return
    end
    ud=get(varargin{1},'UserData');
    fig=varargin{1};
    del=0;
    if ~isempty(ud) && isstruct(ud) && isfield(ud,'aging') && ud.aging>general_param.figure_age_to_rebirth
        oldNumber=get(varargin{1},'Number');
        delete(varargin{1});
        if ~isempty(ud) && isstruct(ud) && isfield(ud,'figure_perso') && ud.figure_perso
            varargout{1}=figure_perso;
        else
            varargout{1}=figure;
        end
        fig=varargout{1};
        del=1;
        info_perso('Rebirth of figure %d into figure %d',oldNumber,get(varargout{1},'Number'));
    elseif ~isempty(ud) && isstruct(ud) && isfield(ud,'aging')
        ud.aging=ud.aging+1;
        set(fig,'UserData',ud);
    elseif ~isempty(ud) && isstruct(ud)
        ud.aging=1;
        set(fig,'UserData',ud);
    else
        set(fig,'UserData',struct('aging',1));
    end
    if ~del
        varargout{:}=clf(varargin{:});
    end
    if ~isempty(param) && isfield(param,'batch_mode') && ~isempty(param.batch_mode)  && param.batch_mode
        set(varargout{1},'Visible','off');
    end
end
