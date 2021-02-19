function varargout = mkdir_perso(varargin)
    global within_mkdir_perso;
    global within_warning_perso;
    within_mkdir_perso = true;
    if nargout>0
        varargout = cell(1, nargout);
        [varargout{:}] = mkdir_helper(varargin{:});
    else
        mkdir_helper(varargin{:});
    end
    if nargin>1
        dir=fullfile(varargin{:});
    else
        dir = varargin{1};
    end
    status = fileattrib(dir,'+w','u g','s') && fileattrib(dir,'-w -x','o','s');
    if ~status
        if ~isempty(within_warning_perso) && within_warning_perso
            warning_perso('Failed to set permissions recursively for directory "%s"',dir);
        else
            warning('Failed to set permissions recursively for directory "%s"',dir);
        end
    end
    within_mkdir_perso = false;
end