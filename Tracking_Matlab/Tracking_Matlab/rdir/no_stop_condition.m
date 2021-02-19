function [res,old_su,su,Cxm,Cym,no_final_energy,SD_from_base,SD_ite,processed_old]=...
    no_stop_condition(init,tt,Cxm,Cym,Psize,shift,check_area_every,new_step_total,last_step_total,old_su,su,new_step,small_step_limit,no_final_energy,...
    SD_from_base,SD_ite,processed_old,Imagee)
%%
    res=[];
%%
    switch init
        case 1 % intialize
            % initialization of empty array in the call to the function
%%            
        case 2 %update
%%
        case 3 % test
            res=false;
    end
end