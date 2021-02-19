function [res,old_su,su,Cxm,Cym,no_final_energy,SD_from_base,SD_ite,processed_old]=...
    stop_condition_number(init,tt,Cxm,Cym,Psize,shift,check_area_every,new_step_total,last_step_total,old_su,su,new_step,t,no_final_energy,...
    SD_from_base,SD_ite,processed_old,Imagee)
    global param;
    if param.AC_method>=1000
        error('Stop condition stop_condition_curve apply only to curve, not to level sets');
    end
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
                if param.stop_on_max_iter<=tt
                    res=10;
                else
                    res=-1;
                end
                    
    end
end