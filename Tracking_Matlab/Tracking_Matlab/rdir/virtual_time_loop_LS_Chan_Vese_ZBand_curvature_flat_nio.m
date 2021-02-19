function [Cxm,Cym,su,old_su]=...
            virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,...
            dxa,dx,dxxs,dxx,dxxxa,dxxx,dxxxxs,dxxxx,...
            dya,dy,dyys,dyy,dyyya,dyyy,dyyyys,dyyyy,...
            ddl0ma,ddl0m,t,tt,param_set)
          % we use in this case in lagrangian band base energy, non corrected
        % from slope in z, from slope in z, which mean that we have a gaussian over z value
        % not over space distances. It kills somewhat the idea of Bandwidth
        % we no longer use Chan and Vese but only an outside region which contains all but the 0 level set, curvature of the 0 level set
        % curve only, tension term is the length ("surface time dirac") of zero level set.
     
        
        global Level_set_fct;
        global param
%         global Imagee
        global new_step;
        global rns;
        global Image_param;
        global ImageeDer;

        %%
%         if 0
%             %% 10 14
%             radius=floor(min(size(Level_set_fct))/2);
%             center=size(Level_set_fct)/2;
%             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
%             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
%             Rad=Xpos.^2+Ypos.^2;
%             Rad(Rad(:,:)>radius^2)=radius^2;
%             test=sqrt(radius^2-Rad);
%             figure_perso; surf(test);
%             % that's not the curvature but the 4th derivative
%             Der=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1);
%             curv=Der(:,:,10)+Der(:,:,14);
%             figure_perso; contourf(curv); colorbar;
%     %         center1=center(1);
%     %         center2=center(2);
%             theo=(-15).*Xpos.^4.*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-7/2)+( ...
%               -15).*Ypos.^4.*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-7/2)+( ...
%               -18).*Xpos.^2.*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-5/2)+( ...
%               -18).*Ypos.^2.*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-5/2)+( ...
%               -6).*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-3/2);
%             figure_perso; contourf(theo); colorbar;
%             figure_perso; imshow(curv./theo/2); colormap jet; colorbar;
%             tmp_curv=mathematica_generated_LS_Band_flat_curv_noi(Der,Level_set_fct,lambda,kappa,sigma_used,extensionmax,...
%                     0,0,0,c1_,c2_,c3_,Imagee,param.epsilon,param.Bandwidth);
%             figure_perso; imshow((tmp_curv-min(min(tmp_curv(isfinite(tmp_curv)))))/max(max(tmp_curv(isfinite(tmp_curv))-min(min(tmp_curv(isfinite(tmp_curv))))))); colorbar;
%             figure_perso; surf(tmp_curv);
%             
%             
%             
%             %%
%             radius=floor(min(size(Level_set_fct))/10);
%             center=size(Level_set_fct)/2;
%             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
%             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
%             test=sin(Xpos/radius).*sin(Ypos/radius);
%             figure_perso; surf(test);
%             % that's not the curvature but the 4th derivative
%             Der=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1);
%             curv=Der(:,:,10)+Der(:,:,14);
%             figure_perso; contourf(curv); colorbar;
%     %         center1=center(1);
%     %         center2=center(2);
%             theo=2.*radius.^(-4).*sin(radius.^(-1).*Xpos).*sin(radius.^(-1).*Ypos);
%             figure_perso; contourf(theo); colorbar;
%             figure_perso; imshow(curv./theo/2); colormap jet; colorbar;
%             
%             %%
% %             radius=floor(min(size(Level_set_fct))/2);
% %             center=size(Level_set_fct)/2;
% %             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
% %             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
% %             Rad=Xpos.^2+Ypos.^2;
% %             Rad(Rad(:,:)>radius^2)=radius^2;
% %             test=sqrt(radius^2-Rad);
% %             figure_perso; surf(test);
% %             % that's not the curvature but the 4th derivative
% %             curv=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1);
% %             figure_perso; contourf(sqrt(curv(:,:,3).^2+curv(:,:,5).^2)); colorbar;
% %     %         center1=center(1);
% %     %         center2=center(2);
% %             theo=sqrt(Rad);
% %             figure_perso; contourf(theo); colorbar;
% %             figure_perso; contourf(curv./theo); colorbar;
%     %%
% 
% %             radius=floor(min(size(Level_set_fct))/10);
% %             center=size(Level_set_fct)/2;
% %             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
% %             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
% %             test=sin(Xpos/radius).*sin(Ypos/radius);
% %             figure_perso; surf(test);
% %             % that's not the curvature but the 4th derivative
% %             curv=Curvature_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1);
% %             figure_perso; contourf(curv); colorbar;
% %     %         center1=center(1);
% %     %         center2=center(2);
% %             theo=(1/16).*a.*radius.^(-1).*((-1)+2.*a.^2+cos(2.*radius.^(-1).*Xpos)) ...
% %                   .*((-5)+8.*a.^2+4.*cos(2.*radius.^(-1).*Xpos)+cos(4.*radius.^(-1) ...
% %                   .*Xpos)).*(1+(-2).*a.^2.*((-1)+2.*a.^2+cos(2.*radius.^(-1).*Xpos)) ...
% %                   .^(-1).*cot(radius.^(-1).*Xpos).^2).^(-1/2).*csc(radius.^(-1).* ...
% %                   Xpos).^7.*(1+(-1).*a.^2.*csc(radius.^(-1).*Xpos).^2).^(-1/2).*(1+ ...
% %                   a.^2.*cos(2.*radius.^(-1).*Xpos).*csc(radius.^(-1).*Xpos).^4).^( ...
% %                   -2);
% %             figure_perso; contourf(theo); colorbar;
% %             figure_perso; contourf(curv./theo); colorbar;
%         end
        %%
            [Der,rns]=Derivatives_LS(Level_set_fct, param.(param_set).LS_dx,param.(param_set).LS_dy, param.(param_set).LS_alpha,param.(param_set).LS_algo_diff, 1,1,4);
%         ImageeDer=Derivatives_LS(Imagee, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,1);
        ImageeDer=[];
        % put boundary to the derivative, radius cannot be shorter than 1
        % px and longer than let's say 50 times the size of the image.
        % Let's work in absolute values
        maxLap4=6; % Radius =1;
        Radius=10*max(size(Imagee));
        minLap4=6/Radius^3;
        Der(Der<-maxLap4)=-maxLap4;
        Der(Der>maxLap4)=maxLap4;
        Der(Der<0 & Der>-minLap4)=0;
        Der(Der>0 & Der<minLap4)=0;
%         if 0
%             tmp4=any(any(~isfinite(Der)));
%             tmp5=any(any(~isfinite(Level_set_fct)));
%             disp(['Non finite in Der : ' num2str(tmp4,'%d')]);
%             disp(['Non finite in Level_set_fct : ' num2str(tmp5,'%d')]);
%             tmp3=Der./Level_set_fct;
%             tmp3(~isfinite(tmp3))=0;
%             tmp6=median(mean(tmp3));
%             figure_perso; contourf(tmp3,0:(tmp6/1000):(tmp6/10)); colorbar;
%         end
%         continuous_heaviside=HeavisideThetaApprox(Level_set_fct,param.epsilon);
        % took from Chung and Vese 2005, LNCS 3757
        
        % from Xu and Wang 2008, LNAI 5227
%         c1_=sum(sum(Imagee.*continuous_heaviside))/sum(sum(continuous_heaviside));
%         c2_=sum(sum(Imagee.*(1-continuous_heaviside)))/sum(sum((1-continuous_heaviside)));
        c1_=c1; c2_=c2;
        c3_=Image_param.c3;
        lambdaContour=Image_param.Lcontour;

%%
% sigma_used=0;
dl0m=0;
%%
%% curvature contribution
% if 0
% %     tmp_curv=mathematica_generated_LS_Band_flat_curv_noi(Der,Level_set_fct,lambda,kappa,sigma_used,extensionmax,...
% %             0,0,0,c1_,c2_,c3_,Imagee,ImageeDer,param.epsilon,param.Bandwidth,dl0m);
% %     tmp_dl=mathematica_generated_LS_Band_flat_curv_noi(Der,Level_set_fct,0,kappa,sigma_used,extensionmax,...
% %             lambdaInside,lambdaOutside,lambdaContour,c1_,c2_,c3_,Imagee,ImageeDer,param.epsilon,param.Bandwidth,dl0m);
%         %% energies
%     [Ekappa,Esigma,Edl,Ein,Eout,Econ]=mathematica_generated_LS_ZBand_Energy_flat_curv_noi_debug(Der,Level_set_fct,lambda,kappa,sigma_used,extensionmax,...
%             lambdaInside,lambdaOutside,lambdaContour,c1_,c2_,c3_,param.epsilon,param.Bandwidth,dl0m);
%     figure_perso; imshow((Level_set_fct+max(max(abs(Level_set_fct))))/(2*max(max(abs(Level_set_fct))))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Level_set_fct)),'%g')}); %ok
%     figure_perso; imshow(Ein/max(max(Ein))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Ein)),'%g')}); %ok
%     figure_perso; imshow(Eout/max(max(Eout))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Eout)),'%g')}); %ok
%     figure_perso; imshow(Econ/max(max(Econ))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Econ)),'%g')}); %ok
%     figure_perso; imshow(Edl/max(max(Edl))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Edl)),'%g')}); %ok
%     figure_perso; imshow(Esigma/max(max(Esigma))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Esigma)),'%g')}); % ok
%     figure_perso; imshow(Ekappa/(2*nanmean(nanmean(Ekappa)))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str((2*nanmean(nanmean(Ekappa))),'%g')}); %ok
%      %%   
%         
% %             tmp4=any(any(~isfinite(tmp_curv)));
% %             tmp5=any(any(~isfinite(tmp_dl)));
% %             disp(['Non finite in tmp_curv : ' num2str(tmp4,'%d')]);
% %             disp(['Non finite in tmp_dl : ' num2str(tmp5,'%d')]);
% %             disp(['Non finite in Der :' num2str(any(any(any(~isfinite(Der)))),'%d')]);
% %     figure_perso; imshow(any(isfinite(tmp_curv),3));
% %     figure_perso; imshow((tmp_curv-max(max(abs(tmp_curv))))/(2*max(max(abs(tmp_curv))))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-max(max(abs(tmp_curv))),'%g') '0' num2str(max(max(abs(tmp_curv))),'%g')});
% %     any(any(tmp_curv~=0 & isfinite(tmp_curv)));
% %     figure_perso; imshow(tmp_dl/max(max(tmp_dl))); colormap jet
% % %     figure_perso; contourf(Level_set_fct);
% % %     figure_perso; contourf(tmp_curv./tmp_dl); colorbar;
% % %     tmp_dd=abs(DiracDeltaApprox(Level_set_fct,param.epsilon));
% % %     figure_perso; contourf(tmp_dd); colorbar;
% % %     tmp_dd=abs(DiracDeltaPrimeApprox(Level_set_fct,param.epsilon));
% % %     figure_perso; contourf(tmp_dd); colorbar;
% % %     tmp_dd=abs(DiracDeltaApprox(Level_set_fct,param.epsilon));
% % %     figure_perso; contourf(tmp_dd>1e-4); colorbar;
% % %     tmp_dd=abs(DiracDeltaPrimeApprox(Level_set_fct,param.epsilon));
% % %     figure_perso; contourf(tmp_dd>1e-4); colorbar;
% end
% if 0
% %% evolution
%     tmp_in=mathematica_generated_LS_ZBand_flat_curv_noi(Der,Level_set_fct,0,kappa,sigma_used,extensionmax,...
%     lambdaInside,0,0,c1_,c2_,c3_,Imagee,ImageeDer,param.epsilon,param.Bandwidth,dl0m);
%     disp(['Non finite in tmp_in : ' num2str(any(any(isnan(tmp_in))),'%d')]);
%     figure_perso; imshow((tmp_in+prctile(abs(tmp_in(:)),99))/(2*prctile(abs(tmp_in(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_in(:)),99),'%g') '0' num2str(prctile(abs(tmp_in(:)),99),'%g')});    
%     title('Inside data link');
%     
%     tmp_out=mathematica_generated_LS_ZBand_flat_curv_noi(Der,Level_set_fct,0,kappa,sigma_used,extensionmax,...
%         0,lambdaOutside,0,c1_,c2_,c3_,Imagee,ImageeDer,param.epsilon,param.Bandwidth,dl0m);
%     disp(['Non finite in tmp_out : ' num2str(any(any(isnan(tmp_out))),'%d')]);
%     figure_perso; imshow((tmp_out+prctile(abs(tmp_out(:)),99))/(2*prctile(abs(tmp_out(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_out(:)),99),'%g') '0' num2str(prctile(abs(tmp_out(:)),99),'%g')});    
%     title('outside data link');
%     
%     tmp_con=mathematica_generated_LS_ZBand_flat_curv_noi(Der,Level_set_fct,0,kappa,sigma_used,extensionmax,...
%         0,0,lambdaContour,c1_,c2_,c3_,Imagee,ImageeDer,param.epsilon,param.Bandwidth,dl0m);
%     disp(['Non finite in tmp_con : ' num2str(any(any(isnan(tmp_con))),'%d')]);
%     figure_perso; imshow((tmp_con+prctile(abs(tmp_con(:)),99))/(2*prctile(abs(tmp_con(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_con(:)),99),'%g') '0' num2str(prctile(abs(tmp_con(:)),99),'%g')});    
%     title('Contour data link');
%     
%     tmp_curv=mathematica_generated_LS_ZBand_flat_curv_noi(Der,Level_set_fct,lambda,kappa,0,extensionmax,...
%         0,0,0,c1_,c2_,c3_,Imagee,ImageeDer,param.epsilon,param.Bandwidth,dl0m);
%     disp(['Non finite in tmp_curv : ' num2str(any(any(isnan(tmp_curv))),'%d')]);
%     figure_perso; imshow((tmp_curv+prctile(abs(tmp_curv(:)),99))/(2*prctile(abs(tmp_curv(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_curv(:)),99),'%g') '0' num2str(prctile(abs(tmp_curv(:)),99),'%g')});
%     title('Curvature');
%     
%     tmp_sig=mathematica_generated_LS_ZBand_flat_curv_noi(Der,Level_set_fct,lambda,0,sigma_used,extensionmax,...
%         0,0,0,c1_,c2_,c3_,Imagee,ImageeDer,param.epsilon,param.Bandwidth,dl0m);
%     disp(['Non finite in tmp_sig : ' num2str(any(any(isnan(tmp_sig))),'%d')]);
%     figure_perso; imshow((tmp_sig+prctile(abs(tmp_sig(:)),99))/(2*prctile(abs(tmp_sig(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_sig(:)),99),'%g') '0' num2str(prctile(abs(tmp_sig(:)),99),'%g')});
%     title('tension energy');
%     
%     figure_perso; plot(-20:20,DiracDeltaApprox(-20:20,param.Bandwidth));
%     
% %%
% end
new_step_=mathematica_generated_LS_ZBand_flat_curv_noi(Der,Level_set_fct,lambda,kappa,sigma_used,extensionmax,...
    lambdaInside,lambdaOutside,lambdaContour,c1_,c2_,c3_,Imagee,ImageeDer,param.(param_set).epsilon,param.(param_set).Bandwidth,dl0m);
thresh=prctile(abs(new_step_(:)),99);
new_step_(new_step_>thresh)=thresh;
new_step_(new_step_<-thresh)=-thresh;
% if 0
%     figure_perso; imshow((new_step_+max(max(abs(new_step_))))/(2*max(max(abs(new_step_))))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-max(max(abs(new_step_))),'%g') '0' num2str(max(max(abs(new_step_))),'%g')});
% end
if any(any(~isfinite(new_step_)))
      warning_perso('rescue localized nan');
      [II,JJ]=meshgrid(1:size(new_step_,2),1:size(new_step_,1));
      xyi=JJ(~isfinite(new_step_))+(II(~isfinite(new_step_))-1)*size(new_step_,1);
      for ii_=1:length(xyi)
         surrounding=[(xyi(ii_)-size(new_step_,1)-1):(xyi(ii_)-size(new_step_,1)+1) ...
             xyi(ii_)-1 xyi(ii_)+1 ...
             (xyi(ii_)+size(new_step_,1)-1):(xyi(ii_)+size(new_step_,1)+1)];
         surrounding(surrounding<1)=[];
         surrounding(surrounding>numel(new_step_))=[];
        tmp_1=nanmean(new_step_(surrounding));
        if ~isempty(tmp_1)
             new_step_(xyi(ii_))=tmp_1;
        end
      end
end

% if 0
%     tmp4=any(any(~isfinite(Der)));
%     tmp5=any(any(~isfinite(Level_set_fct)));
%     disp(['Non finite in Der : ' num2str(tmp4,'%d')]);
%     disp(['Non finite in Level_set_fct : ' num2str(tmp5,'%d')]);
%     tmp6=any(any(~isfinite(new_step)));
%     disp(['Non finite in new_step : ' num2str(tmp6,'%d')]);
%     
%     figure_perso; imshow((new_step_-max(max(abs(new_step_))))/(2*max(max(abs(new_step_))))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTicklabel',{ num2str(-max(max(abs(new_step_))),'%g') '0' num2str(max(max(abs(new_step_))),'%g')});
% end
new_step=param.(param_set).adaptative_new_step/prctile(abs(new_step_(:)),90);
if lambda~=0 && kappa~=0
    Level_set_fct=Level_set_fct-min(new_step,rns)*evol_eq_sign*new_step_;
else
    Level_set_fct=Level_set_fct-new_step*evol_eq_sign*new_step_;
end
        
        
end