function [Ekappa,Esigma,Edl,Ein,Eout,Econ]=energy_framework(Cxm,dx,dxx,dxxx,dxxxx,Cym,dy,dyy,dyyy,dyyyy,...
    dl0m,ddl0m,t,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,c1,c2,param_set)
global param;
global Image_param
global Level_set_fct

shift = Image_param.shift;
Psize = param.(param_set).Psize;

% if param.AC_method<1000
%     x=x_((1+shift):(param.Psize+shift))';
%     dx=dx_((1+shift):(param.Psize+shift));
%     dxx=dxx_((1+shift):(param.Psize+shift));
%     dxxx=dxxx_((1+shift):(param.Psize+shift));
%     dxxxx=dxxxx_((1+shift):(param.Psize+shift));
%     y=y_((1+shift):(param.Psize+shift))';
%     dy=dy_((1+shift):(param.Psize+shift));
%     dyy=dyy_((1+shift):(param.Psize+shift));
%     dyyy=dyyy_((1+shift):(param.Psize+shift));
%     dyyyy=dyyyy_((1+shift):(param.Psize+shift));
%     dl0m=dl0m_((1+shift):(param.Psize+shift));
%     ddl0m=ddl0m_((1+shift):(param.Psize+shift));
% else
% %     [Lap2x,Lap2y,dt]=Curvature_LS_2(Level_set_fct, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,lambda*kappa); % lambda*kappa is used only for dt
% end
if param.(param_set).AC_method>=1000
            [Der,dummy]=Derivatives_LS(Level_set_fct, param.(param_set).LS_dx,param.(param_set).LS_dy, param.(param_set).LS_alpha,param.(param_set).LS_algo_diff, 1,1,Image_param.Der_order);
%         if Image_param.ImDer_order>0
%             ImageeDer=Derivatives_LS(Imagee, param.LS_dx,param.LS_dy, param.LS_alpha,param.LS_algo_diff, 1,1,Image_param.ImDer_order);
%         else
%             ImageeDer=[];
%         end
        if Image_param.Der2_order>0
            [Der2,dummy]=Derivatives_LS(Level_set_fct, param.(param_set).LS_dx,param.(param_set).LS_dy, param.(param_set).LS_alpha,param.(param_set).LS_algo_diff2, 1,1,Image_param.Der2_order);
        else
            Der2=[];
        end
end

%%
% switch param.AC_method
%     case 1020
%         c3=Image_param.c3;
%         lambdaContour=Image_param.Lcontour;
%         [Ekappa,Esigma,Edl,Ein,Eout,Econ]=mathematica_generated_LS_Band_Energy(Lap2x,Lap2y,Level_set_fct,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,lambdaContour,c1,c2,c3,param.epsilon,param.Bandwidth);
%     case 1021
%         c3=Image_param.c3;
%         lambdaContour=Image_param.Lcontour;
%         [Ekappa,Esigma,Edl,Ein,Eout,Econ]=mathematica_generated_LS_Band_Energy_flat_curv(Lap2x,Lap2y,Level_set_fct,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,lambdaContour,c1,c2,c3,param.epsilon,param.Bandwidth);
%     otherwise
        if isfield(Image_param,'c3')
            c3=Image_param.c3;
        end
        if isfield(Image_param,'Lcontour')
            lambdaContour=Image_param.Lcontour;
        end
        if param.(param_set).AC_method>=20 && param.(param_set).AC_method<1000
            [Ekappa,Esigma,Edl,Ein,Eout]=Image_param.mathematica_generated_energy(Cxm((1+shift):(Psize+shift),t)',dx((1+shift):(Psize+shift)),dxx((1+shift):(Psize+shift)),...
                        dxxx((1+shift):(Psize+shift)),dxxxx((1+shift):(Psize+shift)),Cym((1+shift):(Psize+shift),t)',...
                        dy((1+shift):(Psize+shift)),dyy((1+shift):(Psize+shift)),dyyy((1+shift):(Psize+shift)),...
                        dyyyy((1+shift):(Psize+shift)),dl0m((1+shift):(Psize+shift)),ddl0m((1+shift):(Psize+shift)),...
                        lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,lambdaContour,c1,c2,c3,BandWidth);
            Econ = nan;
        elseif param.(param_set).AC_method>=1000
            [Ekappa,Esigma,Edl,Ein,Eout,Econ]=Image_param.mathematica_generated_energy(Der,Level_set_fct,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,lambdaContour,c1,c2,c3,param.(param_set).epsilon,param.(param_set).Bandwidth,[],Der2);
        else
            [Ekappa,Esigma,Edl,Ein,Eout]=Image_param.mathematica_generated_energy(Cxm((1+shift):(Psize+shift),t)',dx((1+shift):(Psize+shift)),dxx((1+shift):(Psize+shift)),...
                        dxxx((1+shift):(Psize+shift)),dxxxx((1+shift):(Psize+shift)),Cym((1+shift):(Psize+shift),t)',...
                        dy((1+shift):(Psize+shift)),dyy((1+shift):(Psize+shift)),dyyy((1+shift):(Psize+shift)),...
                        dyyyy((1+shift):(Psize+shift)),dl0m((1+shift):(Psize+shift)),ddl0m((1+shift):(Psize+shift)),...
                        lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,c1,c2);
            Econ = nan;
        end
        
       Ekappa=sum(sum(Ekappa));
       Esigma=sum(sum(Esigma));
       Edl=sum(sum(Edl));
       Ein=sum(sum(Ein));
       Eout=sum(sum(Eout));
       Econ=sum(sum(Econ)); 
% end