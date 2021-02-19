function saveFigAsTif(arg,name,varargin)
        global param;
    if isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java
        return 
    end

    orig_mode=get(arg,'PaperPositionMode');
    set(arg,'PaperPositionMode','auto');
    drawnow;
%     I=hardcopy(arg,'-Dzbuffer','-r0');
    I=print(fig,'-RGBImage');
    set(arg,'PaperPositionMode',orig_mode);
    if nargin>2
        imwrite(I,name,'tif',varargin{:});
    else
        imwrite(I,name,'tif');
    end
end
