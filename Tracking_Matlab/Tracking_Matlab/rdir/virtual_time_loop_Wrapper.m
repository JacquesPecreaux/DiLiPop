function              [Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
                 tt,new_step_total,last_step_total,t,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su]=...
            virtual_time_loop_Wrapper(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,t,tt,param_set)
% consider when implementing the full scheme in level set the paper of chan, esedoglu, and nikolova, 2006, siam J appl. math vol 66 , pp 1632- about approximating the edge of the contour and
% convexity of minimization

global virtual_time_loop_kernel;

%         global presentation_movie;
%         global ty;
% global continue_loop;
% global force_resample;
% global tt;

%global min_new_step_x max_new_step_x min_new_step_y max_new_step_y % last_step_total
%global new_step_total 
% global rns new_step_x new_step_y new_step_total new_step

%% 
% here come all init common to all non level set methods
%%

%% gradient                
            dxa=diff(Cxm(:,t)); dya=diff(Cym(:,t));
            dx((1+shift):(Psize+shift))=(dxa((1+shift):(Psize+shift))+dxa((1+shift-1):(Psize+shift-1)))./2; dy((1+shift):(Psize+shift))=(dya((1+shift):(Psize+shift))+dya((1+shift-1):(Psize+shift-1)))./2;
            dxxs=diff(dxa); dyys=diff(dya);
            dxx((shift):(Psize+shift+1))=dxxs((shift-1):(Psize+shift)); dyy((shift):(Psize+shift+1))=dyys((shift-1):(Psize+shift));
            dxxxa=diff(dxx); dyyya=diff(dyy);
            dxxx((1+shift):(Psize+shift))=(dxxxa((1+shift):(Psize+shift))+dxxxa((1+shift-1):(Psize+shift-1)))./2; dyyy((1+shift):(Psize+shift))=(dyyya((1+shift):(Psize+shift))+dyyya((1+shift-1):(Psize+shift-1)))./2;
            dxxxxs=diff(dxxxa); dyyyys=diff(dyyya);
            dxxxx((1+shift):(Psize+shift))=dxxxxs((shift):(Psize+shift-1)); dyyyy((1+shift):(Psize+shift))=dyyyys((shift):(Psize+shift-1));

            ddl0ma=diff(dl0m(:));
            ddl0m((1+shift):(Psize+shift))=(ddl0ma((1+shift):(Psize+shift))+ddl0ma((1+shift-1):(Psize+shift-1)))./2;
%% call the kernel

[Cxm,Cym,new_step_total,last_step_total,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su]=...
            virtual_time_loop_kernel(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,...
            dxa,dx,dxxs,dxx,dxxxa,dxxx,dxxxxs,dxxxx,...
            dya,dy,dyys,dyy,dyyya,dyyy,dyyyys,dyyyy,...
            ddl0ma,ddl0m,t,[],param_set);



%% cyclic boundaries

            %%
%             Cxm(1:shift,t+1)=Cxm((Psize+1):(Psize+shift),t+1); Cym(1:shift,t+1)=Cym((Psize+1):(Psize+shift),t+1);
%             Cxm((Psize+shift+1):(Psize+2*shift),t+1)=Cxm((shift+1):(2*shift),t+1); Cym((Psize+shift+1):(Psize+2*shift),t+1)=Cym((shift+1):(2*shift),t+1);
            [Cxm(:,t+1),Cym(:,t+1)]=boundary_conditions(Cxm(:,t+1),Cym(:,t+1),Psize,shift,param_set);
%% avoid getting out of the image           
            % 
            Cxm(Cxm(:,t+1)<1,t+1)=1;
            Cxm(Cxm(:,t+1)>size(Imagee,1),t+1)=size(Imagee,1);
            Cym(Cym(:,t+1)<1,t+1)=1;
            Cym(Cym(:,t+1)>size(Imagee,2),t+1)=size(Imagee,2);
%% Nan check 
NaN_checker;
%             if any(isnan(Cxm((1+shift):(Psize+shift),t+1))) || any(isnan(Cym((1+shift):(Psize+shift),t+1)))
%                 force_resample=1;
%                 [Cxm((1+shift):(Psize+shift),t+1),Cym((1+shift):(Psize+shift),t+1),reset_shape]=...
%                     Nan_fixer(Cxm((1+shift):(Psize+shift),t+1),Cym((1+shift):(Psize+shift),t+1),1);
%                 if reset_shape
%                     old_su=[];
%                     continue_loop=1;
%                     t=2;
%                     tt=2; %tt is the "virtual time for gradient descent
%                     new_step_total=1;
%                     force_resample=0;
%                     [Cxm(:,t+1),Cym(:,t+1)]=Create_starting_shape([],Psize,1,shift,[],[]);
%                 end
%                     % all nan should have been removed here
%                                 %%cyclic boundaries
%                     [Cxm(:,t+1),Cym(:,t+1)]=boundary_conditions(Cxm(:,t+1),Cym(:,t+1),Psize,shift);
%             end
%% loop check and resample            
% resample_AC;
% %             if ((mod(tt,resample_each)==0) || force_resample ) && tt~=2
% %                 force_resample=0;
% %                 
% %                 %%%equally spaced
% %                 dxa=diff(Cxm(:,t+1)); dya=diff(Cym(:,t+1));
% %                 length_=sqrt(dxa.^2+dya.^2);
% %                 % cutting little loops if there are some
% %                 [x0,y0,segments]=selfintersect(Cxm((1+shift):(Psize+shift),t+1),Cym((1+shift):(Psize+shift),t+1));
% %                 if ~isempty(x0)
% %                    for ik_=1:size(segments,1)
% %                        if segments(ik_,1)>segments(ik_,2)
% %                            first_p=segments(ik_,2)+shift;
% %                            last_p=segments(ik_,1)+shift;
% %                        else
% %                            first_p=segments(ik_,1)+shift;
% %                            last_p=segments(ik_,2)+shift;
% %                        end
% %                        l_in=sum(length_(first_p:(last_p-1)));
% %                        l_out=sum(length_((shift+1):(first_p-1)))+sum(length_(last_p:(Psize+shift)));
% %                        if l_in>l_out
% %                            [Cxm,Cym]=loop_cutter(last_p,first_p,t,Cxm,Cym,shift,Psize);
% %                        else
% %                            [Cxm,Cym]=loop_cutter(first_p,last_p,t,Cxm,Cym,shift,Psize);
% %                        end
% %                    end
% %                     %%cyclic boundaries
% %                     Cxm(1:shift,t+1)=Cxm((Psize+1):(Psize+shift),t+1); Cym(1:shift,t+1)=Cym((Psize+1):(Psize+shift),t+1);
% %                     Cxm((Psize+shift+1):(Psize+2*shift),t+1)=Cxm((shift+1):(2*shift),t+1); Cym((Psize+shift+1):(Psize+2*shift),t+1)=Cym((shift+1):(2*shift),t+1);
% % 
% %                     dxa=diff(Cxm(:,t+1)); dya=diff(Cym(:,t+1));
% %                     length_=sqrt(dxa.^2+dya.^2);
% %                 end
% %                 
% %                 % resampling
% %                 
% %                 [Cxm((shift+1):(Psize+shift),t+1),Cym((shift+1):(Psize+shift),t+1),dl0m((shift+1):(Psize+shift))]=...
% %                     equal_spacer(length_((shift+1):(Psize+shift)),Psize,Cxm((shift+1):(Psize+shift),t+1),Cym((shift+1):(Psize+shift),t+1),dl0m((shift+1):(Psize+shift)));
% %                 
% %                 
% %                   [Cxm(:,t+1),Cym(:,t+1),dl0m]=boundary_conditions(Cxm(:,t+1),Cym(:,t+1),Psize,shift,dl0m);
% %             else
% %                 [Cxm(:,t+1),Cym(:,t+1)]=boundary_conditions(Cxm(:,t+1),Cym(:,t+1),Psize,shift);
% %             end        
end