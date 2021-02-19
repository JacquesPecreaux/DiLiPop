function new_step=get_time_step_size_CFL_type_OF(new_step_,param_set)
    global param;
    %param.LS_dx,param.LS_dy
    % related to CFL condition in the way Osher and Fedkiw express it p 30

    new_step=param.(param_set).adaptative_new_step*min(param.(param_set).LS_dx,param.(param_set).LS_dy)^4/max(abs(new_step_(:)));
    
    
 end