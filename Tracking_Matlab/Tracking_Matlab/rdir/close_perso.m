function close_perso(fig3)
global param;
    if isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java
        return 
    end
    if ishandle(fig3)
        close(fig3);
    end
end