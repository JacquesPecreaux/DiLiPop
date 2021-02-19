function cache_working_dir_timer(obj, ~, ~)
    % retrieve call stack
    global upper_fct;
    top_m_file=get_call_stack;
    % (isdeployed || ~feature('isdebugmode')) => work-around to avoid
    % firing when debugging
    tmp_upper_fct=get_upper_fct;
    if (isdeployed || ~feature('isdebugmode')) && ((length(top_m_file)<=3) || ...
            (~isdeployed && ~isempty(upper_fct) && ~strcmp(upper_fct,tmp_upper_fct)))
       working_dir_move;
       stop(obj);
       delete(obj);
       evalin('base','clear working_dir_cache_on_cleanup');
    end
end