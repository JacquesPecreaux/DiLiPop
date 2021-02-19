function varargout = imshow_perso(varargin)
        global param;
    if isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java
        if nargout>0
            varargout{1:nargout}=[];
        end
        return 
    end
    if nargout>0
        varargout = cell(1, nargout);
        [varargout{:}] = imshow(varargin{:});
    else
        imshow(varargin{:});
    end
