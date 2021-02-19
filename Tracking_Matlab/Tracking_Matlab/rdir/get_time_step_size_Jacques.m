function new_step=get_time_step_size_Jacques(new_step_,param_set)
    global param;
    %param.LS_dx,param.LS_dy
    new_step=param.(param_set).adaptative_new_step/prctile(abs(new_step_(:)),90);
    
    
 end