function              [Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
                 tt,new_step_total,last_step_total,t,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su]=...
            virtual_time_loop_Level_Set_Wrapper(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,t,tt,param_set)
% consider when implementing the full scheme in level set the paper of chan, esedoglu, and nikolova, 2006, siam J appl. math vol 66 , pp 1632- about approximating the edge of the contour and
% convexity of minimization

% global Level_set_fct;
global virtual_time_loop_kernel;
global Level_set_fct;
global force_resample;
global param;
global number_of_reset_on_nan;
%% 
% here come all init common to all level set methods

%% backward compatibility
            last_step_total=0;
            new_step_total=0;
        dx=0;
        dxx=0;
        dxxx=0;
        dxxxx=0;
        dy=0;
        dyy=0;
        dyyy=0;
        dyyyy=0;
        ddl0m=0;
        global new_step;
        global rns;
        global reinit_params;
        new_step=1e100;
        rns=1;
%%
[Cxm,Cym,su,old_su]=...
            virtual_time_loop_kernel(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,[],[],[],[],[],[],[],[],[],[],...
            [],[],[],[],[],[],[],[],t,tt,param_set); %,...
%             dxa,dx,dxxs,dxx,dxxxa,dxxx,dxxxxs,dxxxx,...
%             dya,dy,dyys,dyy,dyyya,dyyy,dyyyys,dyyyy,...
%             ddl0ma,ddl0m);
global heuristic_params;
if length(heuristic_params)>1 % we run preliminary params tuning
    return;
end

%% nan check
% NaN_checker;


%% extract contour for stop condition and display
end