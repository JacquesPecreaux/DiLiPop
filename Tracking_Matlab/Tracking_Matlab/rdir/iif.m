function res=iif(cond,val_true,val_false)
    if cond
        if ~ischar(val_true)
            res=val_true;
        else
            res=evalin('caller', val_true);
        end
    else
        if ~ischar(val_false)
            res=val_false;
        else
            res=evalin('caller',val_false);
        end
    end
end
        