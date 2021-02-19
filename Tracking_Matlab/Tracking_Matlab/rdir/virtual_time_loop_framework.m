function [Edl_total2,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,Ekappa_total,Esigma_total,Edl_total,...
    tt,new_step_total,last_step_total,t,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su,res,Ein_total,Eout_total,Econ]=...
    virtual_time_loop_framework(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
    text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,~,evol_eq_sign,...
    last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
    shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,t,subcall,param_set)
    
%% TODO
% removing su and old_su

% t is the current time and I use t+1 as the candidate for new contour
%%
    
        global virtual_time_loop_kernel_wrapper;
        global presentation_movie;
        global ty;
%         global continue_loop;
        global force_resample;
        global Level_set_fct;

        global min_new_step_x max_new_step_x min_new_step_y max_new_step_y 
        global rns new_step
%         global tt;
        global param;
        global Image_param;
        
         
        continue_loop=1;
%         t=2; % was the real time...
        tt=2; %tt is the "virtual time for gradient descent
        new_step_total=1;
        force_resample=0;
        global heuristic_params;
       [~,old_su,su,Cxm,Cym,no_final_energy,SD_from_base,SD_ite,processed_old]=...
           Image_param.stop_condition_fct(1,[],Cxm,Cym,Psize,shift,check_area_every,new_step_total,1,[],[],new_step,small_step_limit,no_final_energy,...
            [],[],[],[],param_set); % initialize stop condition at the beginning of the loop

%%        
        
        while (continue_loop) %loop in virtual time
           
%% call the wrapper
[Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
                 tt,new_step_total,last_step_total,t,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su]=...
            virtual_time_loop_kernel_wrapper(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            [],evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,t,tt,param_set);
if length(heuristic_params)>1 % we run preliminary params tuning
    return;
end
           
%% Nan check         
NaN_checker;
% I should check here if some other parameters lambda ... are not non as
% well
%% display
            if ((mod(tt,display_every_n)==0) || tt==2) %?% && (real_t>=3)
                if ~exist('fig3','var')
                    fig3=[];
                end
                fig3=clear_create_figure_perso(fig3,'Units','normalized','position',[0.1 0.1 0.8 0.8]);
                hold off
                if param.(param_set).save_level_set && param.(param_set).AC_method>=1000
                    imwrite(uint16((Level_set_fct/200+0.5)*(2^16-1)),[Image_param.mov_name(1:(length(Image_param.mov_name)-4)) '_LSconv.tif'],'tif','WriteMode','append','compression',param.(param_set).compression_stack,'Description',param2str(param));
                end
                if param.(param_set).AC_method>=1000
                    plot_current_level_set(tt);
                else
                    I=imadjust(Imagee);
    %                 I=I(size(I,1):-1:1,:);
                    imshow_perso(I);
                    drawnow_perso;
                    hold on
                    if presentation_movie
                        plot_ij(Cxm((shift+1):(Psize+shift+1),t+1),Cym((shift+1):(Psize+shift+1),t+1),'-r','LineWidth',2);
%                         colormap summer
                        % better than winter
                    else
                        plot_ij(last_disp_Cxm((shift+1):(Psize+shift+1)),last_disp_Cym((shift+1):(Psize+shift+1)),'-m','LineWidth',2);
                        plot_ij(Cxm((shift+1):(Psize+shift+1),t+1),Cym((shift+1):(Psize+shift+1),t+1),'-r','LineWidth',2);
                        plot_ij(last_disp_Cxm((shift+1):(shift+1)),last_disp_Cym((shift+1):(shift+1)),'om');
                        plot_ij(Cxm((shift+1):(shift+1),t+1),Cym((shift+1):(shift+1),t+1),'or');
                        plot_ij(Cxm((Psize+shift+1):(Psize+2*shift),t+1),Cym((Psize+shift+1):(Psize+2*shift),t+1),'+k');
                        plot_ij(Cxm((1):(shift),t+1),Cym((1):(shift),t+1),'+k');
                        %colormap summer
                    end
                drawnow_perso;
                end
                if presentation_movie
                    if isfield(param.(param_set),'presentation_movie_text') && ~isempty(param.(param_set).presentation_movie_text) && param.(param_set).presentation_movie_text
                        text_={['iteration tt=' num2str(tt,'%d')] ...
                            ['Tai_Yao iteration=' num2str(ty,'%d')]};
                        if param.(param_set).presentation_movie_text==1
                            text(10,10,text_,...
                            'color','m','fontsize',12,'FontWeight','Bold',...
                            'interpreter','none','VerticalAlignment','Top','HorizontalAlignment','Left')
                        else
                            title(text_,...
                            'color','m','fontsize',12,'FontWeight','Bold',...
                            'interpreter','none');
                        end
                    end
                   MakeQTMovie('addfigurejp2',gcf_perso); 
                end
                if param.(param_set).AC_method<1000
                    last_disp_Cxm=Cxm(:,t+1); last_disp_Cym=Cym(:,t+1);
                end
                
            end
            if ((mod(tt,energy_every_n)==0)) %?% && (real_t>=3)
                [Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total]=mathematica_generated_energy_classic(Cxm((1+shift):(Psize+shift),t)',dx((1+shift):(Psize+shift)),dxx((1+shift):(Psize+shift)),dxxx((1+shift):(Psize+shift)),dxxxx((1+shift):(Psize+shift)),Cym((1+shift):(Psize+shift),t)',dy((1+shift):(Psize+shift)),dyy((1+shift):(Psize+shift)),dyyy((1+shift):(Psize+shift)),dyyyy((1+shift):(Psize+shift)),dl0m((1+shift):(Psize+shift)),ddl0m((1+shift):(Psize+shift)),lambda,kappa,sigma_used,extensionmax,lambdaInside,lambdaOutside,c1,c2);
%                 Ekappa_total=sum(Ekappa); Esigma_total=sum(Esigma); Edl_total=sum(Edl); Ein_total=sum(Ein); Eout_total=sum(Eout);
                message=sprintf('   ---> image #%d t=%d Ekappa=%g Esigma=%g Edl=%g Ein=%g Eout=%g Etotal=%g',real_t,tt,Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Ekappa_total+Esigma_total+Edl_total);
                disp(message);
                message=sprintf('   ---> min_new_step_x=%d max_new_step_x=%g min_new_step_y=%g max_new_step_y=%g',min_new_step_x,max_new_step_x,min_new_step_y,max_new_step_y);
                disp(message);
            end
%%  resampling
if force_resample
    force_resample=0;
    resample_AC;
end
%% stop condition part 2 or increment loop
%
        
%        
   if (tt>=max_iter)
       [res,old_su,su,Cxm,Cym,no_final_energy,SD_from_base,SD_ite,processed_old]=...
            Image_param.stop_condition_fct(3,tt,Cxm,Cym,Psize,shift,check_area_every,new_step_total,last_step_total,old_su,su,new_step,t,no_final_energy,...
            SD_from_base,SD_ite,processed_old,Imagee,param_set);
        if res>0
            msg=sprintf('Max number of iterations reached but stop condition succeeded:');
            disp(msg);
            continue_loop=0;
        else
            msg=sprintf('Max number of iterations reached  new_step_total/Psize=%g',new_step);
            disp(msg);
            continue_loop=0;
            res=9;
        end
   elseif ((mod(tt,check_area_every)==0))
       [res,old_su,su,Cxm,Cym,no_final_energy,SD_from_base,SD_ite,processed_old]=...
            Image_param.stop_condition_fct(3,tt,Cxm,Cym,Psize,shift,check_area_every,new_step_total,last_step_total,old_su,su,new_step,t,no_final_energy,...
            SD_from_base,SD_ite,processed_old,Imagee,param_set);
       if res>0
            msg=sprintf('End with stop condition:');
            disp(msg);
            continue_loop=0;
       else
           continue_loop=1;
       end
   end
%% prepare next ite
%     if continue_loop
       tt=tt+1;
       if param.(param_set).AC_method<1000
            Cxm(:,t)=Cxm(:,t+1); Cym(:,t)=Cym(:,t+1);
       end
        if ((mod(tt,check_area_every)==0) )
%             Image_param.stop_condition_fct...
        end
    if ~continue_loop
        disp(sprintf('END on iteration # %d',tt));
    end
%            Cxm(:,t)=Cxm(:,t+1); Cym(:,t)=Cym(:,t+1);
%% report end of iteration

            if (text_each_ite)
                message=sprintf('image #%d virtual_t=%d new_step=%g timestep=%g',real_t,tt,new_step,adaptative_new_step/rns);
                disp(message);
            end


        end; %for virtual time
        
        
        Ekappa_total=nan;
        Esigma_total=nan;
        Edl_total=nan;
        Ein_total=nan;
        Eout_total=nan;
        Econ=nan;

        if (no_final_energy2==0) && (isempty(subcall) || ~subcall )
            try
                [Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Econ]=energy_framework(Cxm,...
                    dx,dxx,dxxx,...
                    dxxxx,Cym,dy,...
                    dyy,dyyy,dyyyy,...
                    dl0m,ddl0m,...
                    t,lambda,kappa,sigma_used,extensionmax,lambdaInside,lambdaOutside,c1,c2,param_set);
%                     Ekappa_total=sum(Ekappa); Esigma_total=sum(Esigma); Edl_total=sum(Edl); Eout_total=sum(Eout);
                message=sprintf('   ---> image #%d t=%d Ekappa=%g Esigma=%g Edl=%g Ein=%g Eout=%g Econ=%g',real_t,tt,Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Econ);
                disp(message);
            catch error_
               warning_perso('Failed to compute energy\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
               no_final_energy2=0; % unsure it's fine, done on Nov 26th
            end
       else
           no_final_energy2=0; % unsure it's fine, done on Nov 26th
       end
       Edl_total2=Edl_total^2;
       if ~(isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java) && exist('fig3','var') && ishandle(fig3)
            close_perso(fig3); 
       end
      if ~(isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java) && exist('fig_LS','var') && ishandle(fig_LS)
            close_perso(fig_LS);
      end
end %end subfct
