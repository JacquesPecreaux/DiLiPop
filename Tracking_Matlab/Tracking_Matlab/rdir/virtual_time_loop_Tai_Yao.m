function              [Edl_total2,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,Ekappa_total,Esigma_total,Edl_total,...
                 tt,new_step_total,last_step_total,t,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su,res,Ein_total,Eout_total,Econ]=...
            virtual_time_loop_Tai_Yao(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,t,subcall,param_set)
        
       test_area=1;
       global current_c1;
       global current_c2;
       global param;
       global enlarge_starting_shape_;
       global no_final_energy2__;
       global ty;
       % initialised on the first frame by old method then keep the optimized one of previous frame

       c1=current_c1;
       c2=current_c2;
       ty=1;
       while test_area
           
           if c1<c2
               c1_old = c1;
               c2_old = c2;
               c1 = c2_old;
               c2 = c1_old;
           end
           
            info_perso('Current (for next iter) c1=%g  c2=%g',c1,c2);
            [Edl_total2,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,Ekappa_total,Esigma_total,Edl_total,...
                     tt,new_step_total,last_step_total,t,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su,res,Ein_total,Eout_total,Econ]=...
                virtual_time_loop_framework(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
                text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
                antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
                shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,t,subcall,param_set);
            % note that lambda inside and outside are set to 1
          if no_final_energy2__
                no_final_energy2=1;
          end
            Inside=poly2mask(Cym((shift):(Psize+shift+1),t+1),Cxm((shift):(Psize+shift+1),t+1),...
                size(Imagee,1),size(Imagee,2));
            new_c1=mean2(Imagee(Inside));
            new_c2=mean2(Imagee(~Inside));
            
            if new_c1<new_c2
                ta=sqrt((new_c2-c1)^2+(new_c1-c2)^2); 
            else
                ta=sqrt((new_c1-c1)^2+(new_c2-c2)^2); 
            end
            
            test_area=ta>param.(param_set).Tai_Yao_cx_dist_stop;
            c1=new_c1;
            c2=new_c2;
            ty=ty+1;
            if test_area && enlarge_starting_shape_~=1
                  mx=mean(Cxm(:,t));
                  my=mean(Cym(:,t));
                  Cxm(:,t)=enlarge_starting_shape_*(Cxm(:,t)-mx)+mx;
                  Cym(:,t)=enlarge_starting_shape_*(Cym(:,t)-my)+my;
            end
            info_perso('Tai and Yao iter=%d current cx evolution %g',ty,ta);
       end
       
       if (tt>=3) && res>=10 % succesfully detected
            current_c1=c1;
            current_c2=c2;
            info_perso('Optimized c1=%g  c2=%g',c1,c2);
       end
end
        
        
        
        
        
        
        
        
        
            
