function findKillOmeroTimers
    objs = timerfindall;
    for ii_=1:length(objs)
        if ~isempty(objs(ii_).TimerFcn) && strcmp(func2str(objs(ii_).TimerFcn),'omeroKeepAlive/doKeepAlive')
            stop(objs(ii_));
            delete(objs(ii_));
        end
    end
end