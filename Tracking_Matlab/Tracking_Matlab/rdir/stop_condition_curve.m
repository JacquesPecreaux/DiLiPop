function [res,old_su,su,Cxm,Cym,no_final_energy,SD_from_base,SD_ite,processed_old]=...
    stop_condition_curve(init,tt,Cxm,Cym,Psize,shift,check_area_every,new_step_total,last_step_total,old_su,su,new_step,t,no_final_energy,...
    SD_from_base,SD_ite,processed_old,Imagee,param_set)
    global param;
    if param.(param_set).AC_method>=1000
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
            if (new_step<param.(param_set).small_step_limit)
                disp('Stopped by minimal size of steps');
                res=10;
            elseif (tt>=3) && (((new_step_total-last_step_total)/last_step_total)>param.(param_set).antidivergence)
                msg=sprintf('Stopped by antidivergence condition ((new_step_total-last_step_total)/last_step_total)=%g',((new_step_total-last_step_total)/last_step_total));
                disp(msg);
                Cxm((shift+1):(Psize+shift),1)=(size(Imagee,2))/2+(size(Imagee,2)-100)/2*sign(cos(2*pi/(Psize)*(1:Psize)+pi)).*(abs(cos(2*pi/(Psize)*(1:Psize)+pi))).^(1/4); Cym((shift+1):(Psize+shift),1)=(size(Imagee,1))/2+(size(Imagee,1)-100)/2*sign(sin(2*pi/(Psize)*(1:Psize)+pi)).*(abs(sin(2*pi/(Psize)*(1:Psize)+pi))).^(1/4);
                Cxm(1:shift,1)=Cxm((Psize+1):(Psize+shift),1); Cym(1:shift,1)=Cym((Psize+1):(Psize+shift),1);
                Cxm((Psize+shift+1):(Psize+2*shift),1)=Cxm((shift+1):(2*shift),1); Cym((Psize+shift+1):(Psize+2*shift),1)=Cym((shift+1):(2*shift),1);
                no_final_energy=1;
                res=1;
            else
                su=polyarea(Cxm((shift):(Psize+shift+1),t+1),Cym((shift):(Psize+shift+1),t+1)); % repeat the last point at the beginning
                if ~isempty(old_su)
                    tmp_area_rate=(abs(su-old_su)/su);
                    if (abs(su-old_su)/su)<(param.(param_set).area_diff_stop*check_area_every);
                        disp('End with Area condition');
                        res=11;
                    end
                else
                    res=0;
                    tmp_area_rate=NaN;
                end
                message=sprintf('    ----> area %g\t area_rate %g',su,tmp_area_rate/check_area_every);
                disp(message);
                    
                old_su=su;
            end
    end
end