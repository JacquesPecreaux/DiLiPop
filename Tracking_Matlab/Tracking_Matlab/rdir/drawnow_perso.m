function drawnow_perso(varargin)
    global param;
    if ~(isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java)
        drawnow(varargin{:});
    end