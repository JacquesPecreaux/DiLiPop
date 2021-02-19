function [status2,segmentation, Cxm_,Cym_,fig4,Imagee_,Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Econ]=explicit_2D_space_only_v0p2_no_t_p(image_stem,padding,...
    first,number,format_image,kap,sig,black_object,timestep,phase_contrast_preprocess_span,...
    c1,c2,Lin,Lout,adjust_image,smoothing_for_region_values,adaptative_new_step,absolute_lamba_X,normalise,imhist_nb,param_set)

if ~exist('param_set','var') || isempty(param_set)
    param_set = 'tk1_tk2';
end
persistent previous_call_hash;
candidate_hash = DataHash({image_stem,padding,...
    first,number,format_image,kap,sig,black_object,timestep,phase_contrast_preprocess_span,...
    c1,c2,Lin,Lout,adjust_image,smoothing_for_region_values,adaptative_new_step,absolute_lamba_X,normalise,imhist_nb,param_set});
persistent res;
if ~isempty(previous_call_hash) && ~isempty(res) && strcmp(previous_call_hash,candidate_hash)
    status2=res{1};
    segmentation=res{2};
    Cxm_=res{3};
    Cym_=res{4};
    fig4=res{5};
    Imagee_=res{6};
    Ekappa_total=res{7};
    Esigma_total=res{8};
    Edl_total=res{9};
    Ein_total=res{10};
    Eout_total=res{11};
    Econ=res{12};
    disp('Skip contour computation as already computed - use recorded result')
    return
end


errorvar.message='No error'; errorvar.identifier='none'; errorvar.stack=[];
status=-1024;   
global work_path;
global param;
%%
%TO DEBUG contour
% param.(param_set).presentation_movie = 1; % to generate the convergence movie.

%%
try
    %%
    f=figure_perso; % needed to avoid to polute the report
[Cxm_,Cym_,fig4,Imagee_,segmentation,Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Econ] = active_contour_real_time_loop(param.(param_set).area_diff_stop, image_stem, ...
      param.(param_set).max_iter ,param.(param_set).small_step_limit, param.(param_set).display_every_n,...
        param.(param_set).energy_every_n,param.(param_set).text_each_ite,param.resol,param.(param_set).no_final_energy,param.(param_set).check_area_every,...
            param.(param_set).final_fig_save,param.extra,param.sp6,param.(param_set).memory,param.(param_set).Tsize,param.(param_set).Psize,param.(param_set).extensionmax,param.(param_set).resample_each,...
     param.(param_set).decimate,param.(param_set).con_movie,param.(param_set).lambda_,param.(param_set).antidivergence,adjust_image,c1,c2,param.(param_set).evol_eq_sign,...
     padding,first,number,format_image,kap,sig,black_object,timestep,phase_contrast_preprocess_span,...
     Lin,Lout,smoothing_for_region_values,adaptative_new_step,absolute_lamba_X,normalise,imhist_nb,param.(param_set).recompute_c1_c2_mode,param.(param_set).no_final_energy2_,...
     param.(param_set).enlarge_starting_shape,param.(param_set).Cxm_init,param.(param_set).Cym_init,param.(param_set).Contour_init_mode,[],param.(param_set).filter_image,...
     param.(param_set).mask_image,param.(param_set).imtophat_image,param.(param_set).maskFromInitialization_image, ...
     param.(param_set).initialization_mask,param.(param_set).clahe_image,param.(param_set).kalman_image,param.(param_set).overwrite_results,param_set);
%%
    
    status=-status;

catch error_
    segmentation = [];
    Cxm_ = [];
    Cym_ = [];
    fig4 = [];
    Imagee_ = [];
    Ekappa_total = [];
    Esigma_total = [];
    Edl_total = [];
    Ein_total = [];
    Eout_total = [];
    Econ = [];
    
    nom=sprintf('END ON ERROR %s',image_stem);
    disp(nom);
    reporter(nan,error_,mfilename);
    nom=sprintf('dump_%s_%s',mfilename,strrep(datestr(now,0),':','-')); %the ':' are not allowed in file name under Windows
    info_perso(['dumping state after error in ' nom]);
    save(fullfile(work_path,nom));
    errorvar = error_;
end
 if ishandle(f)
         close(f);
 end
reporter(status,errorvar,image_stem);
status2=2*(status>0);

res = {status2,segmentation, Cxm_,Cym_,fig4,Imagee_,Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Econ};
previous_call_hash = candidate_hash;

end


