function [Ir]=imadjust_perso(varargin)
global param
if nargin==1
    varargin{2}=stretchlim_perso(varargin{1});
    if isempty(param) && isfield(param,'max_level') && isempty(param.max_level)
        step = 1/param.max_level;
    else
        step = 1/255;
    end
    lowHigh=varargin{2};
    if sum(sum(varargin{1}<=lowHigh(1)))/numel(varargin{1})>0.01
        lowHigh(1) = max(0,lowHigh(1) - step);
    end
    if sum(sum(varargin{1}>=lowHigh(2)))/numel(varargin{1})>0.01
        lowHigh(2) = min(1,lowHigh(2) + step);
    end
    varargin{2} = lowHigh;
end

if varargin{2}(1)~=varargin{2}(2)
    Ir=imadjust(varargin{:});
else
    warning_perso('Low- and High-level equal in imadjust_perso...Black frame?');
    Ir=varargin{1};
end

