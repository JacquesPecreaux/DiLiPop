function onCleanup_helper
    keep_alives = timerfind('Name','Working Dir Cache');
    if size(keep_alives) > 0,
        disp('Stopping all Working Dir Cache timers');
        for i=1:size(keep_alives),
            stop(keep_alives(i));
            delete(keep_alives(i));
        end
    end
    disp('onCleanup_helper will move cached working dir in place');
    working_dir_move;
end