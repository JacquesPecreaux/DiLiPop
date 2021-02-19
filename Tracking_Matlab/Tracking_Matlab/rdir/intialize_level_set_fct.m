function intialize_level_set_fct(Cxm,Cym,param_set)
% called from init optim method
global Level_set_fct;
global Level_set_fct_backup;
global Imagee;
global Image_param;

global param;
if param.(param_set).reuse_initial_contour~=2
    Level_set_fct=Image_param.reinit_lsf(2*poly2mask(Cym,Cxm,size(Imagee,1),size(Imagee,2))-1,...
        param.(param_set).LS_dx,param.(param_set).LS_dy, param.(param_set).LS_alpha,param.(param_set).LS_algo_diff_resamp, param.(param_set).reinit_iterations);
else
    Level_set_fct=Level_set_fct_backup;
end
if param.(param_set).reuse_initial_contour==1
    Level_set_fct_backup=Level_set_fct;
    %param.(param_set).reuse_initial_contour=2;
end
end