function [new_step_]=...
            virtual_time_loop_LS_Chan_Vese_ZBand_curv_flat_nio_cont_1_step(lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
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
        % curve only, tension term is the length ("surface time dirac") of
        % zero level set.
        
%% initialization     
        global Image_param;
        
        mathematica_generated_debug=Image_param.mathematica_generated_debug;
        mathematica_generated=Image_param.mathematica_generated;
        
        global Level_set_fct;
        global param
%         global Imagee
        global new_step;
        global rns;
        global ImageeDer;
        global maxLS;
        global heuristic_params;
        persistent Der Der2;
 %% unit test derivatives , curvature and derivatives
%         if 0
%             % 10 14
%             radius=floor(min(size(Level_set_fct))/2);
%             center=size(Level_set_fct)/2;
%             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
%             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
%             Rad=Xpos.^2+Ypos.^2;
%             Rad(Rad(:,:)>radius^2)=radius^2;
%             test=sqrt(radius^2-Rad);
%             figure_perso; surf(test);
%             % that's not the curvature but the 4th derivative
%             Der=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             curv=Der(:,:,10)+Der(:,:,14);
%             figure_perso; contourf(curv); colorbar;
%     %         center1=center(1);
%     %         center2=center(2);
%             theo=(-15).*Xpos.^4.*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-7/2)+( ...
%               -15).*Ypos.^4.*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-7/2)+( ...
%               -18).*Xpos.^2.*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-5/2)+( ...
%               -18).*Ypos.^2.*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-5/2)+( ...
%               -6).*(radius.^2+(-1).*Xpos.^2+(-1).*Ypos.^2).^(-3/2);
%             theo((Rad(:,:)>radius^2))=0;
%             figure_perso; contourf(theo); colorbar;
%             figure_perso; imshow((curv-theo)./(2*theo)+0.5); colormap jet; colorbar;
% %             figure_perso; imshow((curv/theo)/2); colormap jet; colorbar;
%             scale=10000; % if 10 the plot_perso color range logarithmically from curv 10x smaller to curv 10x bigger
%             n1=curv./theo;
%             figure_perso; imshow(log(n1)/(2*log(scale)*log(10))+0.5);colormap jet ;colorbar
%             
%             param.LS_algo_diff='WENO' 
%             Der1=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             param.LS_algo_diff='CWENO4'
%             Der2=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             figure_perso; imshow(((Der1(:,:,1)/max(max(Der1(:,:,1))))-(Der2(:,:,1)/max(max(Der2(:,:,1)))))./(Der1(:,:,1)/max(max(Der1(:,:,1))))+0.5); colormap jet; colorbar;
%             figure_perso; imshow((Der1(:,:,1)-Der2(:,:,1))./Der1(:,:,1)+0.5); colormap jet; colorbar;
%             m1=(Der1(:,:,1)-Der2(:,:,1))./Der1(:,:,1);
%             m1(~isfinite(m1))=NaN;
%             m=nanmax(nanmax(abs(m1)));
%             figure_perso; imshow(m1/(2*m)+0.5); colormap jet; colorbar;
%             n1=Der1(:,:,1)./Der2(:,:,1);
%            
%             
%             tmp_curv=mathematica_generated_LS_Band_flat_curv_noi(Der,Level_set_fct,lambda,kappa,sigma_used,extensionmax,...
%                     0,0,0,c1_,c2_,c3_,Imagee,param.epsilon,param.Bandwidth);
%             figure_perso; imshow((tmp_curv-min(min(tmp_curv(isfinite(tmp_curv)))))/max(max(tmp_curv(isfinite(tmp_curv))-min(min(tmp_curv(isfinite(tmp_curv))))))); colorbar;
%             figure_perso; surf(tmp_curv);
%             
%             
%            
% %% unit test, a second shape, curvature and derivatives
%             radius=floor(min(size(Level_set_fct))/10);
%             center=size(Level_set_fct)/2;
%             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
%             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
%             test=sin(Xpos/radius).*sin(Ypos/radius);
%             figure_perso; surf(test);
%             % that's not the curvature but the 4th derivative
%             Der=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             curv=Der(:,:,10)+Der(:,:,14);
%             figure_perso; contourf(curv); colorbar;
%     %         center1=center(1);
%     %         center2=center(2);
%             theo=2.*radius.^(-4).*sin(radius.^(-1).*Xpos).*sin(radius.^(-1).*Ypos);
%             figure_perso; contourf(theo); colorbar;
%             figure_perso; imshow(curv./theo/2); colormap jet; colorbar;        
%             
%             [Der1,rns]=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             Der2=Check_Derivatives(Xpos,Ypos,radius);
%             for ii__=1:14
%                 figure_perso; imshow(abs(Der1(:,:,ii__)-Der2(:,:,ii__))./abs(Der2(:,:,ii__))); title(['index: ' num2str(ii__,'%d')]); colormap jet; colorbar;
%             end
%             
% %            
%             radius=floor(min(size(Level_set_fct))/10);
%             center=size(Level_set_fct)/2;
%             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
%             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
%             test=Xpos.^4+3*Ypos.^4;
%             figure_perso; surf(test);
% 
%             [Der1,rns]=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             Der2=Check_Derivatives2(Xpos,Ypos,radius);
%             for ii__=1:14
%                 figure_perso; imshow(abs(Der1(:,:,ii__)-Der2(:,:,ii__))./abs(Der2(:,:,ii__))); title(['index: ' num2str(ii__,'%d')]); colormap jet; colorbar;
%             end
% %% compare to param.LS_algo_diff_resamp (use WENO so that everything will be properly initialize)            
%             radius=floor(min(size(Level_set_fct))/10);
%             center=size(Level_set_fct)/2;
%             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
%             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
%             test=sin(Xpos/radius).*sin(Ypos/radius);
%             figure_perso; surf(test);
%             % that's not the curvature but the 4th derivative
%             Der=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             curv=Der(:,:,10)+Der(:,:,14);
%             figure_perso; contourf(curv); colorbar;
%     %         center1=center(1);
%     %         center2=center(2);
%             theo=2.*radius.^(-4).*sin(radius.^(-1).*Xpos).*sin(radius.^(-1).*Ypos);
%             figure_perso; contourf(theo); colorbar;
%             figure_perso; imshow(curv./theo/2); colormap jet; colorbar;        
%             
%             [Der1,rns]=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             [Der2,rns]=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff_resamp, 1,1,4);
%             for ii__=1:14
%                 figure_perso; imshow(abs(Der1(:,:,ii__)-Der2(:,:,ii__))./abs(Der2(:,:,ii__))); title(['index: ' num2str(ii__,'%d')]); colormap jet; colorbar;
%             end
%             
% %            
%             radius=floor(min(size(Level_set_fct))/10);
%             center=size(Level_set_fct)/2;
%             Xpos=((1:size(Level_set_fct,1))-center(1))'*ones(1,size(Level_set_fct,2));
%             Ypos=ones(size(Level_set_fct,1),1)*((1:size(Level_set_fct,2))-center(2));
%             test=Xpos.^4+3*Ypos.^4;
%             figure_perso; surf(test);
% 
%             [Der1,rns]=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,4);
%             [Der2,rns]=Derivatives_LS(test, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff_resamp, 1,1,4);
%             for ii__=1:14
%                 figure_perso; imshow(abs(Der1(:,:,ii__)-Der2(:,:,ii__))./abs(Der2(:,:,ii__))); title(['index: ' num2str(ii__,'%d')]); colormap jet; colorbar;
%             end
% 
% 
%         end
%% compute derivatives
        [Der,dummy]=Derivatives_LS(Level_set_fct, param.(param_set).LS_dx,param.(param_set).LS_dy, param.(param_set).LS_alpha,param.(param_set).LS_algo_diff, 1,1,Image_param.Der_order);
        if Image_param.ImDer_order>0
            ImageeDer=Derivatives_LS(Imagee, param.(param_set).LS_dx,param.(param_set).LS_dy, param.(param_set).LS_alpha,param.(param_set).LS_algo_diff, 1,1,Image_param.ImDer_order);
        else
            ImageeDer=[];
        end
        if Image_param.Der2_order>0
            [Der2,dummy]=Derivatives_LS(Level_set_fct, param.(param_set).LS_dx,param.(param_set).LS_dy, param.(param_set).LS_alpha,param.(param_set).LS_algo_diff2, 1,1,Image_param.Der2_order);
        else
            Der2=[];
        end

%         % put boundary to the derivative, radius cannot be shorter than 1
%         % px and longer than let's say 50 times the size of the image.
%         % Let's work in absolute values
%         maxLap4=6; % Radius =1;
%         Radius=10*max(size(Imagee));
%         minLap4=6/Radius^3;
%         Der(Der<-maxLap4)=-maxLap4;
%         Der(Der>maxLap4)=maxLap4;
%         Der(Der<0 & Der>-minLap4)=0;
%         Der(Der>0 & Der<minLap4)=0;
%% unit test derivatives (no NaN)
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
%% images stuff (data link)        
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
%% unit test energies
% if 0 
%     [Ekappa,Esigma,Edl,Ein,Eout,Econ]=mathematica_generated_debug(Der,Level_set_fct,lambda,kappa,sigma_used,extensionmax,...
%             lambdaInside,lambdaOutside,lambdaContour,c1_,c2_,c3_,param.epsilon,param.Bandwidth,dl0m);
%     figure_perso; imshow((Level_set_fct+max(max(abs(Level_set_fct))))/(2*max(max(abs(Level_set_fct))))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Level_set_fct)),'%g')}); %ok
%     figure_perso; imshow(Ein/max(max(Ein))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Ein)),'%g')}); %ok
%     figure_perso; imshow(Eout/max(max(Eout))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Eout)),'%g')}); %ok
%     figure_perso; imshow(Econ/max(max(Econ))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Econ)),'%g')}); %ok
%     figure_perso; imshow(Edl/max(max(Edl))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Edl)),'%g')}); %ok
%     figure_perso; imshow(Esigma/max(max(Esigma))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str(max(max(Esigma)),'%g')}); % ok
%     figure_perso; imshow(Ekappa/(2*nanmean(nanmean(Ekappa)))); colormap('jet'); colorbar('YTick',[0 1],'YTickLabel',{'0' num2str((2*nanmean(nanmean(Ekappa))),'%g')}); %ok
% end
%% heuristic adjustment of params
if heuristic_params
% evolution WARNING THERE IS A MINUS SIGN BELOW everything checked and
% fine on Aug 4th 2009
    tmp_in=mathematica_generated(Der,Level_set_fct,0,kappa,sigma_used,extensionmax,...
    lambdaInside,0,0,c1_,c2_,c3_,Imagee,ImageeDer,param.(param_set).epsilon,param.(param_set).Bandwidth,dl0m,Der2);
    
    tmp_out=mathematica_generated(Der,Level_set_fct,0,kappa,sigma_used,extensionmax,...
        0,lambdaOutside,0,c1_,c2_,c3_,Imagee,ImageeDer,param.(param_set).epsilon,param.(param_set).Bandwidth,dl0m,Der2);
    
    tmp_con=mathematica_generated(Der,Level_set_fct,0,kappa,sigma_used,extensionmax,...
        0,0,lambdaContour,c1_,c2_,c3_,Imagee,ImageeDer,param.(param_set).epsilon,param.(param_set).Bandwidth,dl0m,Der2);
    
    tmp_curv=mathematica_generated(Der,Level_set_fct,lambda,kappa,0,extensionmax,...
        0,0,0,c1_,c2_,c3_,Imagee,ImageeDer,param.(param_set).epsilon,param.(param_set).Bandwidth,dl0m,Der2);
    
    tmp_sig=mathematica_generated(Der,Level_set_fct,lambda,0,sigma_used,extensionmax,...
        0,0,0,c1_,c2_,c3_,Imagee,ImageeDer,param.(param_set).epsilon,param.(param_set).Bandwidth,dl0m,Der2);
%%    
%     heuristic_params=[median(tmp_in(:)) median(tmp_out(:)) median(tmp_con(:)) median(tmp_curv(:)) median(tmp_sig(:))];
    heuristic_params=[prctile(tmp_in(:),90) prctile(tmp_out(:),90) prctile(tmp_con(:),90) prctile(tmp_curv(:),90) prctile(tmp_sig(:),90)];
    new_step_=[]; % to avoid an error when getting back to caller
    return;
% use debug section above to equilibrate terms
end

%% unit test contribution of each part to evolution
% if 0
%         disp(['Non finite in tmp_in : ' num2str(any(any(isnan(tmp_in))),'%d')]);
%     figure_perso; imshow((tmp_in+prctile(abs(tmp_in(:)),99))/(2*prctile(abs(tmp_in(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_in(:)),99),'%g') '0' num2str(prctile(abs(tmp_in(:)),99),'%g')});    
%     title('Inside data link');
% 
%     disp(['Non finite in tmp_out : ' num2str(any(any(isnan(tmp_out))),'%d')]);
%     figure_perso; imshow((tmp_out+prctile(abs(tmp_out(:)),99))/(2*prctile(abs(tmp_out(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_out(:)),99),'%g') '0' num2str(prctile(abs(tmp_out(:)),99),'%g')});    
%     title('outside data link');
%     
%     disp(['Non finite in tmp_con : ' num2str(any(any(isnan(tmp_con))),'%d')]);
%     figure_perso; imshow((tmp_con+prctile(abs(tmp_con(:)),99))/(2*prctile(abs(tmp_con(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_con(:)),99),'%g') '0' num2str(prctile(abs(tmp_con(:)),99),'%g')});    
%     title('Contour data link');
%     
%     disp(['Non finite in tmp_curv : ' num2str(any(any(isnan(tmp_curv))),'%d')]);
%     figure_perso; imshow((tmp_curv+prctile(abs(tmp_curv(:)),99))/(2*prctile(abs(tmp_curv(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_curv(:)),99),'%g') '0' num2str(prctile(abs(tmp_curv(:)),99),'%g')});
%     title('Curvature');
%     
%      disp(['Non finite in tmp_sig : ' num2str(any(any(isnan(tmp_sig))),'%d')]);
%     figure_perso; imshow((tmp_sig+prctile(abs(tmp_sig(:)),99))/(2*prctile(abs(tmp_sig(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(tmp_sig(:)),99),'%g') '0' num2str(prctile(abs(tmp_sig(:)),99),'%g')});
%     title('tension energy');
% 
%     figure_perso; plot_perso(-20:20,DiracDeltaApprox(-20:20,param.Bandwidth));
% %%
% end
global debug_kappa_sigma
if ~isempty(debug_kappa_sigma) && debug_kappa_sigma
    disp(['kappa=' num2str(kappa,'%g') '  sigma=' num2str(sigma,'%g') '  lambda=' num2str(lambda,'%g')]);
end

%% numerical derivatives, compute next step and limit it
new_step_=mathematica_generated(Der,Level_set_fct,lambda,kappa,sigma_used,extensionmax,...
    lambdaInside,lambdaOutside,lambdaContour,c1_,c2_,c3_,Imagee,ImageeDer,param.(param_set).epsilon,param.(param_set).Bandwidth,dl0m,Der2);
thresh=prctile(abs(new_step_(:)),99);
new_step_(new_step_>thresh)=thresh;
new_step_(new_step_<-thresh)=-thresh;
%% unit test next step
% if 0
%     figure_perso; imshow((-new_step_+prctile(abs(new_step_(:)),99))/(2*prctile(abs(new_step_(:)),99))); colormap('jet'); colorbar('YTick',[0 0.5 1],'YTickLabel',{num2str(-prctile(abs(new_step_(:)),99),'%g') '0' num2str(prctile(abs(new_step_(:)),99),'%g')});
% end
%% rescue localized nan
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
%% unit test remaining NaN
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

end