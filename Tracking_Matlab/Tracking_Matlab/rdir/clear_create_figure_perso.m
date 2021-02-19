function varargout = clear_create_figure_perso(varargin)
    if ishandle(varargin{1})
        varargout{1}=clf_perso(varargin{1},'reset');
    else
        varargout{:}=figure_perso(varargin{2:end});
    end
end
