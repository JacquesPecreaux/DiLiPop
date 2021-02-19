function [virtual_time_loop_optimizer]=init_optim_method(param_set)
% param.AC_method specify the optimization method. It could be either a
% single integer and all the images will be processed with the designated
% method 
% value above 1000 represent level set method

%% general initialization
    global current_c1
    global current_c2
    global Imagee_;
    global param;
    global Image_param;
    global virtual_time_loop_kernel;
    global virtual_time_loop_kernel_wrapper;
    if param.(param_set).AC_method>=1000
        virtual_time_loop_kernel_wrapper=@virtual_time_loop_Level_Set_Wrapper;
    else
        virtual_time_loop_kernel_wrapper=@virtual_time_loop_Wrapper;
    end
        
    %% specific to methods
    Image_param.shift=0; % default case
    switch(param.(param_set).AC_method)
        case 0
                virtual_time_loop_optimizer=@virtual_time_loop_framework;
                virtual_time_loop_kernel=@virtual_time_loop;
                Image_param.mathematica_generated_energy = @mathematica_generated_energy_classic;
                Image_param.shift=2; % linked to tha higher derivatives used
        case 1
                virtual_time_loop_optimizer=@virtual_time_loop_Tai_Yao;
                virtual_time_loop_kernel=@virtual_time_loop; 
                Image_param.mathematica_generated_energy = @mathematica_generated_energy_classic;
                Image_param.shift=2; % linked to tha higher derivatives used
        case 2
                virtual_time_loop_optimizer=@virtual_time_loop_framework;
                virtual_time_loop_kernel=@virtual_time_loop_direct_yolk;
                Image_param.mathematica_generated_energy = @mathematica_generated_energy_classic;
                Image_param.shift=2; % linked to tha higher derivatives used -- shift cannot be smaller than 2
                % this method directly return the contour of a mask. If
                % image is not binary it is converted using Otsu
                % thresholding
                
        case 20 % TODO test
                Image_param.mathematica_generated_energy = @mathematica_generated_Band_Energy;
                
        case 1000 % the original Xu and Wang
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Xu_Wang;
        case 1001 % not sure this one exist really as a different method from 1000
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Xu_Wang_Band;
        case 1010 % Chan et Vese with global curvature
            % mathematica file : LS_Euler-L_jan09
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=[];
            Image_param.mathematica_generated=@mathematica_generated_LS_eq1;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
        case 1020
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_Band_curvature;
        case 1021 % Chan et Vese image term and ostragradski transformed curvature and tension
             % mathematica file :
             % LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1021.nb
             % curvature and length still use the ostrogradski theorem
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1021;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1021;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
        case 1022 % Chan et Vese image term and ostragradski transformed tension
             % mathematica file :
             % LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1022.nb
             % length still use the ostrogradski theorem
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1022;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1022;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
        case 1030
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_Band_curvature_flat_nio;
        case 1031
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio;
        case 1040 % Band based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1040_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1040.nb
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1040;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1040;
            Image_param.Der_order=4;
            Image_param.ImDer_order=2;
            Image_param.Der2_order=0;
      case 1050 % Band based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1050_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1050.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1050;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1050;
            Image_param.Der_order=4;
            Image_param.ImDer_order=1;
            Image_param.Der2_order=0;
      case 1060 % heaviside based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1060_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1060.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1060;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1060;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
      case 1070 % heaviside based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1070_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1060.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1070;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1070;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
      case 1080 % heaviside based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1080_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1060.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1080;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1080;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
      case 1090 % heaviside based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1080_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1060.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1090;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1090;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
      case 1100 % heaviside based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1080_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1060.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1090;
            Image_param.mathematica_generated=@(Der,LevelSetFct,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,lambdaContour,c1,c2,c3,Imagee,ImageeDer,epsilon,BandWidth,dl0m)...
                zeros(size(LevelSetFct));
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
      case 1200 % heaviside based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1080_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1060.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1200;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1200;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
      case 1210 % heaviside based on z, tnesion and curvature using virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_1080_.m
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1060.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1210;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1210;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
     case 1400 
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1400.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1400;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1400;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
     case 1500 
             % mathematica file
             % :LS_Euler-LS_plane_curvature_jul09_z-Band_no_in_out_no_dirac_1400.nb
             % part of functionnal derivatives computed by hand to ensure
             % that no dirac derivatives appears
            virtual_time_loop_optimizer=@virtual_time_loop_framework;
            virtual_time_loop_kernel=@virtual_time_loop_LS_Chan_Vese_ZBand_curvature_flat_nio_cont;
            Image_param.mathematica_generated_debug=@MG_LS_ZBand_Energy_flat_curv_noi_debug_NoDirac1500;
            Image_param.mathematica_generated=@MG_LS_ZBand_flat_curv_noi_NoDirac1500;
            Image_param.mathematica_generated_energy=@MG_LS_ZBand_Energy_flat_curv_noi_NoDirac1500;
            Image_param.Der_order=4;
            Image_param.ImDer_order=0;
            Image_param.Der2_order=0;
            param.(param_set).Lin=param.(param_set).Surface_regul/(Image_param.resolution^2); % this is lambda_sha that code for an energy per surface
    end
%% init numerical scheme
switch (param.(param_set).numerical_scheme)
    case 'Euler'
        Image_param.numerical_scheme=@Euler_scheme;
    case 'TVD_RK3'
        Image_param.numerical_scheme=@TVD_RK3_scheme;
    case 'TVD_RK2'
        Image_param.numerical_scheme=@TVD_RK2_scheme;
end
%% init step size limiter
switch (param.(param_set).get_time_step_size)
    case 'Jacques'
        Image_param.get_time_step_size=@get_time_step_size_Jacques;
    case 'OF_CFL'
        Image_param.get_time_step_size=@get_time_step_size_CFL_type_OF;
    case 'OF_CFL_prctle'
        Image_param.get_time_step_size=@get_time_step_size_CFL_type;
end
%% init Riemann Solver
switch (param.(param_set).rieman_solver)
    case 'Average_upwind'
        Image_param.rieman_solver_fct=@(upwind_minus,upwind_plus,param1,param2) (upwind_minus(param1,param2)+upwind_plus(param1,param2))/2;
    case 'Central_differentiating'
        Image_param.rieman_solver_fct=@(upwind_minus,upwind_plus,param1,param2) upwind_minus(param1,param2);
end
%% init CENT4 if used
if ~isempty(strfind(param.(param_set).LS_algo_diff,'CENT'))
    % step are automatically decided by spacing of the grid
    param.(param_set).LS_dx=1;
    param.(param_set).LS_dy=1;
end
%% stop condition
switch param.(param_set).stop_condition
    case 'stop_condition_surface_SD'
        Image_param.stop_condition_fct=@stop_condition_surface_SD;
    case 'stop_condition_curve'
        Image_param.stop_condition_fct=@stop_condition_curve;
    case 'None' 
        Image_param.stop_condition_fct=@no_stop_condition;
    case 'MaxIter'
        Image_param.stop_condition_fct=@stop_condition_number;
end
%% param.reset_level_sets
if param.(param_set).AC_method>=1000
    switch param.(param_set).reset_level_sets
        case 'reinit_SD'
            Image_param.reinit_lsf=@reinit_SD;
        case 'fast_marching'
            Image_param.reinit_lsf=@perform_redistancing_wrapper;
    end
end    
%% preallocate for speed
global idx_iX; %WENO
global v1X v2X v3X v4X v5X
global data_x_wenoX_1 data_x_wenoX_2 data_x_wenoX_3 data_x_wenoX

global idx_iY; %WENO
global v1Y v2Y v3Y v4Y v5Y
global data_x_wenoY_1 data_x_wenoY_2 data_x_wenoY_3 data_x_wenoY

global Level_set_fct;
global delta data_ext
global phi_x_minus phi_x_plus phi_y_minus phi_y_plus phi_x phi_y
global abs_grad_phi H1_abs H2_abs
global Uphi Vphi

global idx_1; % ENO2

if param.(param_set).AC_method>=1000
%% init ENO    
%     if ( ~isempty(strfind(param.LS_algo_diff,'ENO')) && strcmp(param.LS_algo_diff_resamp,param.LS_algo_diff)) || ...
%             isempty(strfind(param.LS_algo_diff,'ENO'))
%         eno_to_init=param.LS_algo_diff_resamp;
%     elseif isempty(strfind(param.LS_algo_diff_resamp,'ENO'))
%         error('JACQ:LsResampStencil','Resampling of level set function must use an ENO stencil');
%     else
% %         error('JACQ:LsDiffStencil','Resampling and euler-lagrange equation must use the same ENO stencil (when the later use an ENO stencil)');
% % WENO no longer use globals!
%     end
%     
%     switch(eno_to_init)
% 		case 'ENO1'
% 		case 'ENO2'
%             idx_1=(3:(size(Level_set_fct,1)+4-2))'*ones(1,size(Level_set_fct,2)+4)+ones(size(Level_set_fct,1)+4-4,1)*((0:(size(Level_set_fct,2)+4-1))*(size(Level_set_fct,1)+4)); % ENO2
% 		case 'ENO3'
% 		case 'WENO'
%             idx_iY=(1:(size(Level_set_fct,1)+6-6))'*ones(1,size(Level_set_fct,2))+ones(size(Level_set_fct,1)+6-6,1)*((0:(size(Level_set_fct,2)-1))*(size(Level_set_fct,1)+6)); % WENO
%             idx_iX=(1:(size(Level_set_fct,2)+6-6))'*ones(1,size(Level_set_fct,1))+ones(size(Level_set_fct,2)+6-6,1)*((0:(size(Level_set_fct,1)-1))*(size(Level_set_fct,2)+6)); % WENO
%         otherwise
% 			error('Desired type of the accuracy is not correctly specified!');
%     end
    %preallocate for speed
%     v1X=zeros(size(Level_set_fct));
%     v1Y=v1X';

%     v2X=v1X; v3X=v1X; v4X=v1X; v5X=v1X;
%     data_x_wenoX_1=v1X; data_x_wenoX_2=v1X; data_x_wenoX_3=v1X; data_x_wenoX=v1X;
% 
%     v2Y=v1Y; v3Y=v1Y; v4Y=v1Y; v5Y=v1Y;
%     data_x_wenoY_1=v1Y; data_x_wenoY_2=v1Y; data_x_wenoY_3=v1Y; data_x_wenoY=v1Y;
    
    phi_x_minus=zeros(size(Level_set_fct)+6);
    phi_x_plus=phi_x_minus;
    phi_y_minus=phi_x_minus;
    phi_y_plus=phi_x_minus;
    phi_x=phi_x_minus;
    phi_y=phi_x_minus;
    abs_grad_phi=phi_x_minus;
    H1_abs=phi_x_minus;
    H2_abs=phi_x_minus;
    Uphi=phi_x_minus;
    Vphi=phi_x_minus;

    delta=phi_x_minus; data_ext=phi_x_minus;
%%
end

end