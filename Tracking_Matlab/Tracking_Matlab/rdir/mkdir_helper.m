function varargout = mkdir_helper(varargin)
    if nargin>1
        parentDir = varargin{1};
    else
        parentDir = fileparts(varargin{1});
    end
    if ~isempty(parentDir) && ~exist(parentDir,'file')
        mkdir_perso(parentDir);
    end
    if nargout>0
        varargout = cell(1, nargout);
        [varargout{:}] = mkdir(varargin{:});
    else
        mkdir(varargin{:});
    end
end
