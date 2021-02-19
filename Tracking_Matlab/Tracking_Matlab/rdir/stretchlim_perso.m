function LOW_HIGH=stretchlim_perso(varargin)
    I=varargin{1};
    global running_mask_BW;
    %global level;
    
    % poor work around
    if all(size(running_mask_BW) == size(varargin{1}))
        if exist('running_mask_BW','var') && ~isempty(running_mask_BW)
            varargin{1}=I(logical(running_mask_BW));
        end
    end
    
    
    LOW_HIGH = stretchlim(varargin{:});
end