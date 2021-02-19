function [varargout] = loadOmero_helper(varargin)
    addpath(fullfile(fileparts(mfilename('fullpath')),'OMERO.matlab'));
    if nargout>0
        varargout=cell(nargout,1);
        [varargout{:}] = loadOmero(varargin{:});
    else
        loadOmero(varargin{:});
        varargout = cell(0);
    end
end