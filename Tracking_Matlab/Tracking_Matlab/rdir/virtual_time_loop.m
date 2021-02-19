function [Cxm,Cym,new_step_total,last_step_total,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su]=...
            virtual_time_loop(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,...
            dxa,dx,dxxs,dxx,dxxxa,dxxx,dxxxxs,dxxxx,...
            dya,dy,dyys,dyy,dyyya,dyyy,dyyyys,dyyyy,...
            ddl0ma,ddl0m,t,~,~)
    
global min_new_step_x max_new_step_x min_new_step_y max_new_step_y last_step_total
global new_step_total rns new_step_x new_step_y new_step_total new_step

%% computing next step
            new_step_x=-(mathematica_generated_eq1(Cxm((1+shift):(Psize+shift),t)',dx((1+shift):(Psize+shift)),dxx((1+shift):(Psize+shift)),dxxx((1+shift):(Psize+shift)),dxxxx((1+shift):(Psize+shift)),Cym((1+shift):(Psize+shift),t)',dy((1+shift):(Psize+shift)),dyy((1+shift):(Psize+shift)),dyyy((1+shift):(Psize+shift)),dyyyy((1+shift):(Psize+shift)),dl0m((1+shift):(Psize+shift)),ddl0m((1+shift):(Psize+shift)),lambda,kappa,sigma_used,extensionmax,lambdaInside,lambdaOutside,c1,c2))'*timestep;
            new_step_y=-(mathematica_generated_eq2(Cxm((1+shift):(Psize+shift),t)',dx((1+shift):(Psize+shift)),dxx((1+shift):(Psize+shift)),dxxx((1+shift):(Psize+shift)),dxxxx((1+shift):(Psize+shift)),Cym((1+shift):(Psize+shift),t)',dy((1+shift):(Psize+shift)),dyy((1+shift):(Psize+shift)),dyyy((1+shift):(Psize+shift)),dyyyy((1+shift):(Psize+shift)),dl0m((1+shift):(Psize+shift)),ddl0m((1+shift):(Psize+shift)),lambda,kappa,sigma_used,extensionmax,lambdaInside,lambdaOutside,c1,c2))'*timestep;

            min_new_step_x=min(new_step_x);
            max_new_step_x=max(new_step_x);
            min_new_step_y=min(new_step_y);
            max_new_step_y=max(new_step_y);

            last_step_total=new_step_total; 
            new_step_total=sum(sqrt(new_step_x.^2+new_step_y.^2));
             new_step=max(sqrt(new_step_x.^2+new_step_y.^2));

           rns=new_step;
           if (adaptative_new_step>0)
               new_step_x=(adaptative_new_step/new_step)*new_step_x;
               new_step_y=(adaptative_new_step/new_step)*new_step_y;
               new_step_total=sum(sqrt(new_step_x.^2+new_step_y.^2));
               new_step=max(sqrt(new_step_x.^2+new_step_y.^2));
            end

            Cxm((1+shift):(Psize+shift),t+1)=(evol_eq_sign)*new_step_x+Cxm((1+shift):(Psize+shift),t);
            Cym((1+shift):(Psize+shift),t+1)=(evol_eq_sign)*new_step_y+Cym((1+shift):(Psize+shift),t);


 
end 
