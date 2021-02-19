function [Cxm,Cym,new_step_total,last_step_total,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su]=...
            virtual_time_loop_direct_yolk(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,...
            dxa,dx,dxxs,dxx,dxxxa,dxxx,dxxxxs,dxxxx,...
            dya,dy,dyys,dyy,dyyya,dyyy,dyyyys,dyyyy,...
            ddl0ma,ddl0m,t,~,param_set)
    
global min_new_step_x max_new_step_x min_new_step_y max_new_step_y last_step_total
global new_step_total rns new_step_x new_step_y new_step_total new_step

global param;
global Image_param;

%% computing next step            
            
%             im=imclose(Imagee,strel('disk',round(param.yolk_radius/param.resol))); % filling the inside of the yolk
% %             im=imopen(im,strel('disk',round(param.cut_off_small_particles/param.resol))); % get rid of remaining small particles
%            level = prctile(im(:),param.yolk_threshold);
              BW=im2bw(Imagee,graythresh(Imagee));
            [Cxm,Cym]=bw2contour(BW,Cxm,Cym,t+1,param_set);
            
            rns=1; % for compatibility
end 
