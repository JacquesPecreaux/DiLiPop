function [Cxm,Cym,su,old_su]=...
            virtual_time_loop_LS_Xu_Wang(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,...
            dxa,dx,dxxs,dxx,dxxxa,dxxx,dxxxxs,dxxxx,...
            dya,dy,dyys,dyy,dyyya,dyyy,dyyyys,dyyyy,...
            ddl0ma,ddl0m,t,tt,param_set)
        
        
        global Level_set_fct;
        global param
%         global Image_param;

        %%
        
        continuous_heaviside=1/2*(1+2/pi*atan(Level_set_fct/param.(param_set).epsilon));
        % took from Chung and Vese 2005, LNCS 3757
        
        % from Xu and Wang 2008, LNAI 5227
        c1_=sum(sum(Imagee.*continuous_heaviside))/sum(sum(continuous_heaviside));
        c2_=sum(sum(Imagee.*(1-continuous_heaviside)))/sum(sum((1-continuous_heaviside)));
        c_min=min(c1_,c2_);
        c_max=max(c1_,c2_);
        Level_set_fct=Level_set_fct+param.(param_set).adaptative_new_step*(Imagee-(c_max+c_min)/2)*(c_max-c_min);
        disp(['Xu and Wang c_min= ' num2str(c_min,'%g') '  c_max= ' num2str(c_max,'%g')]);
%         Image_param.XW_c_min=c_min;
%         Image_param.XW_c_max=c_max;
end