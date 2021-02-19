function ChoosenGroup = omero_init_helper_secured(varargin)
    res = globalsToStruct;
    if nargout>=1
        ChoosenGroup = omero_init_helper(varargin{:});
    else
        omero_init_helper(varargin{:});
    end
    structToGlobal(res);
    % not before since when reconnecting, I cannot access the persistent
    % Semaphore (not recreated) within omero_init_helper
    global clientAliveSemaphore;
    clientAliveSemaphore.release();

end
