function [Cxm_,Cym_,fig4,Imagee_,segmentation,Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Econ]=active_contour_real_time_loop(varargin)
 global subcall;
 global main_fct_params;
 global Image_param;
 global fig_LS;
 global param;
 global image_stack_global;
 global Level_Set_All;
 % for debugging
 global con_name;
 global last_detection_succeeded;
 global current_c1;
 global current_c2;
 global firstContours_backup;
 %global general_param;
 %global mean_for_bleaching_correct
 global pathMainDirectory;
% global mask_BW_cropped;

%% some initialization have to be done only for topmost instance
 if isempty(subcall) || ~subcall
    main_fct_params=varargin;
%  intiailiase the clock 
    Image_param.start_datavec=datevec(now);
 end

 %% other initialization
area_diff_stop=varargin{1};
name=varargin{2};
max_iter=varargin{3};
small_step_limit=varargin{4};
display_every_n=varargin{5};
energy_every_n=varargin{6};
text_each_ite=varargin{7};
resol=varargin{8};
no_final_energy_=varargin{9};
check_area_every=varargin{10};
final_fig_save=varargin{11};
tag=varargin{12};
frame_rate=varargin{13};
memory=varargin{14};
Tsize=varargin{15};
Psize=varargin{16};
extensionmax=varargin{17};
resample_each=varargin{18};
decimate=varargin{19};
con_movie=varargin{20};
lambda_=varargin{21};
antidivergence=varargin{22};
adjust_image=varargin{23};
c1=varargin{24};
c2=varargin{25};
evol_eq_sign=varargin{26};
padding=varargin{27};
first=varargin{28};
number=varargin{29};
format_image=varargin{30};
kap=varargin{31};
sig=varargin{32};
black_object=varargin{33};
timestep=varargin{34};
phase_contrast_preprocess_span=varargin{35};
% param.(param_set).Lin=varargin{36}; % put below to have param_set defined
% param.(param_set).Lout=varargin{37};
smoothing_for_region_values=varargin{38};
adaptative_new_step=varargin{39};
absolute_lamba_X=varargin{40};
normalise=varargin{41};
imhist_nb=varargin{42};
recompute_c1_c2_mode=varargin{43};
no_final_energy2_=varargin{44};
enlarge_starting_shape=varargin{45};
Cxm_init=varargin{46};
Cym_init=varargin{47};
Contour_init_mode=varargin{48};
if nargin>=49 && ~isempty(varargin{49})
    if strcmp(param.format_image,'image_stack')
        provided_image=nan;
        image_stack_global = varargin{49};
    else
        provided_image = varargin{49};
        image_stack_global = [];
    end
else
    provided_image=[];
    image_stack_global = [];
end
if nargin >= 50
    filter_image=varargin{50};
    if nargin >= 51
        mask_image=varargin{51};
        if nargin >= 52
            imtophat_image=varargin{52};
            if nargin >= 53
                maskFromInitialization_image=varargin{53};
                if nargin >= 54
                    initialization_mask = varargin{54};
                    if nargin >= 55
                        clahe_image = varargin{55};
                        if nargin >= 56
                               kalman_image = varargin{56};
                               if nargin >= 57
                                   overwrite_results = varargin{57};
                                   if nargin >=58
                                       param_set = varargin{58};
                                   end
                               end
                        end
                    end
                end
            end
        end
    end
end
param.(param_set).Lin=varargin{36};
param.(param_set).Lout=varargin{37};

if ~isfield(param.(param_set),'save_level_set')
    param.(param_set).save_level_set=0;
end
if ~isfield(param.(param_set),'numerical_scheme')
    param.(param_set).numerical_scheme='Euler';
end
if ~isfield(param.(param_set),'get_time_step_size')
    param.(param_set).get_time_step_size='Jacques';
end
if ~isfield(param.(param_set),'rieman_solver')
    param.(param_set).rieman_solver='Central_differentiating';
end
if ~isfield(param.(param_set),'LS_algo_diff')
    param.(param_set).LS_algo_diff='CENT';
end
if ~isfield(param.(param_set),'Lcontour')
    param.(param_set).Lcontour=0;
end
    %% case of empty params
    if ~absolute_lamba_X
        error('Non absolute lambda X is buggy and no longer maintained');
    end
    if ~exist('recompute_c1_c2_mode','var') || isempty(recompute_c1_c2_mode)
        recompute_c1_c2_mode=1;
    end
    if ~exist('no_final_energy2_','var') || isempty(no_final_energy2_)
        no_final_energy2_=0;
    end
    if ~exist('enlarge_starting_shape','var') || isempty(enlarge_starting_shape)
        enlarge_starting_shape=1;
    end
    if ~exist('Contour_init_mode','var') || isempty(Contour_init_mode)
        Contour_init_mode=1;
    end
    if ~exist('filter_image','var') || isempty(filter_image)
        filter_image=0;
    end
    if ~exist('mask_image','var') || isempty(mask_image)
       mask_image=[];
    end
    if ~exist('imtophat_image','var') || isempty(imtophat_image)
        imtophat_image=0;
    end
    if ~exist('maskFromInitialization_image','var') || isempty(maskFromInitialization_image)
        maskFromInitialization_image=0;
    end
    if ~exist('initialization_mask','var') || isempty(initialization_mask)
        initialization_mask=0;
    end
	if ~exist('clahe_image','var') || isempty(clahe_image)
        clahe_image=0;
    end
    if ~exist('kalman_image','var') || isempty(kalman_image)
        kalman_image=0;
    end
    if ~exist('Cxm_init','var')
        Cxm_init=[];
    end
    if ~exist('Cym_init','var')
        Cym_init=[];
    end
    if ~exist('overwrite_results','var') || isempty(overwrite_results)
        overwrite_results=0;
    end
%% 
%     if decimate>0
%         loop_array=0:decimate:(number-1);
%     else
%         loop_array=(number-1):decimate:0;
%     end
    
    if decimate > 0
        if param.channel_total > 1
            % param.channel_interest = 1, should start at image 1 so loop 0
            % param.channel_interest = 2, should start at image 2 so loop 1
            loop_array= (0 + (param.channel_interest-1)) : (decimate*param.channel_total) : (number-1); %
        else
            loop_array=0:decimate:(number-1);
        end
    else
        if param.channel_total > 1
            % param.channel_interest = 1, should start at image number-1 so loop 0
            % param.channel_interest = 2, should start at image number so loop 1
            loop_array= (number-1)+(param.channel_interest-2) : (decimate*param.channel_total) : 0; %
        else
            loop_array=(number-1):decimate:0;
        end
    end
    
    
    Cxm_=nan(Psize,length(loop_array)+1);
    Cym_=nan(Psize,length(loop_array)+1);
    fig4=[];
    Imagee_=[];
    Ekappa_total=nan;
    Esigma_total=nan;
    Edl_total=nan;
    Eout_total=nan;
    Ein_total=nan;
    Econ=nan;
    last_detection_succeeded =1;
%% various initialization    
    global force_close_fig;
    force_close_fig = param.(param_set).force_close_fig;
    global Imagee
    global no_save_con
    global mean_for_bleaching_correct;
    global ty;
    ty=0;
    %global real_t;
    real_t=0;
    global enlarge_starting_shape_;
    enlarge_starting_shape_=enlarge_starting_shape;
    global no_final_energy2__
    no_final_energy2__=no_final_energy2_;
    global number_of_reset_on_nan;
    global Level_set_fct;
    global maxLS;
    global heuristic_params;
    heuristic_params=0;
%     global short_name;
    global result_contour;
    no_final_energy2=no_final_energy2_;
    no_final_energy=no_final_energy_;
    p = mfilename('fullpath');
    prog_version=Version_perso(p);
    fig3=figure_perso;
    image_stem=name;
    if ~exist('provided_image','var') || isempty(provided_image)
        provided_image=image_stem;
    end
    
    global presentation_movie
    if isfield(param.(param_set),'presentation_movie')
        presentation_movie = param.(param_set).presentation_movie;
    end
    if isempty(presentation_movie) || ~presentation_movie
        presentation_movie=0;
        no_save_con=0;
    else 
        con_movie=1;
        no_save_con=0;
    end

    param.(param_set).presentation_movie = presentation_movie;



    Image_param.resolution=1e9/resol;
    if memory>0
        Memory=max(round(memory*frame_rate),1);
        if Memory==1
            warning('tension memory value so low that there is none');
        end
    end
    extensionmax=extensionmax/resol; % in unit of px not in %!!!



    
    %%


    if (normalise && adjust_image)
        warning('adjust_image has no effect if normalized is active'); %#ok<WNTAG>
        adjust_image=0;
    end

%% READ IMAGE FOR INITIALIZATIONS
        [Imagee,Imagee_]=read_with_preprocess(image_stem,format_image,padding,first,number+first-1,...
            phase_contrast_preprocess_span,param_set,mask_image,1,...
            adjust_image,filter_image,provided_image,kalman_image,imtophat_image,clahe_image,maskFromInitialization_image);

%     figure_perso; imshow_perso(Imagee); colormap jet; colorbar
    %% INITIALIZE
    if ~isempty(subcall) && ~(subcall)
        Level_set_fct=zeros(size(Imagee));
    end
    %% INITIALIZE OPTIMIZATION METHOD
    [virtual_time_loop_optimizer]=init_optim_method(param_set); % needed before setting the names
   shift=Image_param.shift; % for backward compatibility    
    maxLS=max(size(Imagee));
%% INITIALIZE MOVIE,contour file, etc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(subcall) || ~subcall
    if ~overwrite_results
        if isempty(pathMainDirectory)
        mat_name=unique_name(sprintf('%s_%s.%s',name,tag,short_name),'result.mat'); % not created for level sets
    else
            id = [name((end-3):(end))];
            mat_name=unique_name(sprintf('%s%s_%s.%s',pathMainDirectory,id,tag,short_name),'result.mat');
        end
    else
        if isempty(pathMainDirectory)
        mat_name=[sprintf('%s_%s.%s',name,tag,short_name) 'result.mat'];
        else
            id = [name((end-3):(end))];
            mat_name=[sprintf('%s%s_%s.%s',pathMainDirectory,id,tag,short_name) 'result.mat'];
        end
    end
    con_name=[mat_name(1:(end-11)) '.con'];
    if param.(param_set).AC_method<1000
        if isempty(no_save_con) || ~no_save_con 
            fp=fopen(con_name,'w');
            fprintf(fp,'Explicit_Active_Contour \n%s\n, name: %s\n\1\n',prog_version,image_stem);
            fprintf(fp,'\n');
            fclose_perso(fp);
        end
    end
    if (con_movie && (isempty(no_save_con) || ~no_save_con)) || param.(param_set).save_level_set
        mov_name=[con_name(1:(length(con_name)-4)) '.mov'];
        Image_param.mov_name=mov_name;
%         init_movie(mov_name,size(I,1)+100,size(I,2)+100);
        init_movie_=0;
    end
% convergence movie
     if presentation_movie || (con_movie && (isempty(no_save_con) || ~no_save_con))
        MakeQTMovie('start',[mov_name(1:(length(mov_name)-4)) '_conv.mov']);
        MakeQTMovie('tiffcopy',[mov_name(1:(length(mov_name)-4)) '_conv.tif']);
        MakeQTMovie('framerate',15);    
        MakeQTMovie('quality',0.9);
     end
    if param.(param_set).save_level_set && param.(param_set).AC_method>=1000
        imwrite(uint16((Imagee)*(2^16-1)),[mov_name(1:(length(mov_name)-4)) '_LSconv.tif'],'tif','compression',param.(param_set).compression_stack,'Description',param2str(param));
    end
end
 %%    %%%%%%%%%%%%%%%%%%%% INITIALIZE CONTOUR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(param.(param_set),'fixed_length') && ~isempty(param.(param_set).fixed_length)
    dl0m=((param.(param_set).fixed_length/param.resol)/Psize)*ones(1,Psize+2*shift);
elseif isfield(param.(param_set),'initial_length') && ~isempty(param.(param_set).initial_length)
    dl0m=((param.(param_set).initial_length/param.resol)/Psize)*ones(1,Psize+2*shift);
else
    dl0m=zeros(1,Psize+2*shift);
end
if param.(param_set).AC_method<1000
    [Cxm,Cym,Contour_init_mode]=Create_starting_shape(Contour_init_mode,Psize,Tsize,shift,Cxm_init,Cym_init,first+loop_array(1),1,param_set);
    [Cxm((shift+1):(Psize+shift),1),Cym((shift+1):(Psize+shift),1)]=equal_spacer([],Psize,Cxm((shift+1):(Psize+shift),1),Cym((shift+1):(Psize+shift),1),[],param_set);
    [Cxm(:,1),Cym(:,1)]=boundary_conditions(Cxm(:,1),Cym(:,1),Psize,shift,[],param_set);
    Cxm(:,2)=Cxm(:,1); Cym(:,2)=Cym(:,1);
    last_disp_Cxm=Cxm(:,2); last_disp_Cym=Cym(:,2);
    su=polyarea(Cxm((shift):(Psize+shift+1),1),Cym((shift):(Psize+shift+1),1)); % repeat the last point at the beginning
else
    Create_starting_shape(Contour_init_mode,Psize,Tsize,shift,Cxm_init,Cym_init,first+loop_array(1),1,param_set);
    su=0;
    Cxm=[];
    Cym=[];
    last_disp_Cxm=[];
    last_disp_Cym=[];
end

    [virtual_time_loop_optimizer]=init_optim_method(param_set); % in case initialization uses this very function

%% %%%%%%%%%%%%%%% DISPLAY INITIAL CONTOUR  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %%display
    if ~exist('fig3','var')
        fig3=[];
    end
    fig3=clear_create_figure_perso(fig3);
    hold_perso off
    if param.(param_set).AC_method>=1000
        plot_current_level_set(0);
    else
        I=imadjust(Imagee_);
        imshow_perso(I);
        drawnow_perso;
    %     axis xy % very important for reprensenting in direct axes
        hold_perso on
        plot_ij(Cxm((shift+1):(Psize+shift+1),2),Cym((shift+1):(Psize+shift+1),2),'-og');
    end
    drawnow_perso;
% %% READ IMAGE FOR INITIALIZATIONS (if different preprocessor)
%         [Imagee,Imagee_]=read_with_preprocess(image_stem,format_image,padding,first,number+first-1,phase_contrast_preprocess_span,param_set,mask_image,2,...
%             adjust_image,filter_image,provided_image,kalman_image,imtophat_image,clahe_image,maskFromInitialization_image);

%% INITIlize regularization
    macro_init_regul; 
%% INITIALIZE IMAGE PARAMETERS
if param.(param_set).AC_method<1000
[c1,c2,recompute_c1_c2_mode]=Initialize_Image_params(recompute_c1_c2_mode,0,...
    c1,c2,normalise,smoothing_for_region_values,imhist_nb,black_object,...
    Cxm((shift+1):(Psize+shift+1),1),Cym((shift+1):(Psize+shift+1),1),Imagee_,real_t,param_set);
else
[c1,c2,recompute_c1_c2_mode]=Initialize_Image_params(recompute_c1_c2_mode,0,...
    c1,c2,normalise,smoothing_for_region_values,imhist_nb,black_object,...
    [],[],Imagee_,real_t,param_set);
end

%% READ IMAGE FOR INITIALIZATIONS (if different preprocessor)
        [Imagee,Imagee_]=read_with_preprocess(image_stem,format_image,padding,first,number+first-1,phase_contrast_preprocess_span,param_set,mask_image,2,...
            adjust_image,filter_image,provided_image,kalman_image,imtophat_image,clahe_image,maskFromInitialization_image,c1,c2);
%% heuristic equilibration of params (contour init mode 1100 also go there
%% but with no empty param and before this part of the code is called by
%% main function)
if isempty(sig) || isempty(kap) || isempty(lambda_) || ...
        isempty(param.(param_set).Lin) || isempty(param.(param_set).Lout) || isempty(param.(param_set).Lcontour)
    kap=1e-19;
    sig_=sigma;
    sig=1;
    lambda__=lambda_;
    if isempty(lambda_) || lambda_~=0
        lambda_=1;
    else
        info_perso('Force lambda to zero');
    end
    if isempty(param.(param_set).Lout) || param.(param_set).Lout~=0
        param.(param_set).Lout=1;
    else
        info_perso('Force lambda_out to zero');
    end
    Lin_=param.(param_set).Lin;
    if isempty(param.(param_set).Lin) || param.(param_set).Lin~=0
        param.(param_set).Lin=1;
    else
        info_perso('Force lambda_in to zero');
    end
    Lcon_=Image_param.Lcontour;
    if isempty(Image_param.Lcontour) || Image_param.Lcontour~=0
        Image_param.Lcontour=1;
    else
        info_perso('Force lambda_contour to zero');
    end
    
    heuristic_params=1;
    real_t=memory-2;
    macro_init_regul;
    macro_upate_sigma;
    virtual_time_loop_optimizer(Image_param.lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
      text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
      antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
      shift,lambda,kappa,sigma_used,Image_param.lambdaOutside,c1,c2,timestep,Imagee,0,su,1,1,subcall,param_set);

  % heuristic_params %in out con curv sig
    if (isempty(sig_) || sig_~=0) && (~isempty(lambda_) && lambda_~=0)
        if abs(heuristic_params(5))>0 && abs(heuristic_params(4))>0
            sig=abs(heuristic_params(4))/abs(heuristic_params(5));
        else
            if ~isempty(sig_)
                sig=sig_;
                warning_perso('cannot set heuristic sigma, taking given value');
            else
                sig=sig_;
                warning_perso('cannot set heuristic sigma, use 0 since given value is empty');
            end
        end
    else
        info_perso('Force sigma to 0');
        sig=0;
    end
    
    if param.(param_set).Lin~=0 && param.(param_set).Lout~=0 && abs(heuristic_params(1))>0 && abs(heuristic_params(2))>0
        param.(param_set).Lin=abs(heuristic_params(2))/abs(heuristic_params(1));
    elseif param.(param_set).Lin~=0 && Image_param.Lcontour~=0 && abs(heuristic_params(1))>0 && abs(heuristic_params(3))>0
        param.(param_set).Lin=abs(heuristic_params(3))/abs(heuristic_params(1));
    elseif Lin_~=0 && ~isempty(Lin_)
        param.(param_set).Lin=Lin_;
        warning_perso('cannot set heuristic Lin, taking given value');
    else isempty(Lin_)
        param.(param_set).Lin=0;
        warning_perso('cannot set heuristic Lin, use 0 since given value is empty');
    end
       
    if Image_param.Lcontour~=0 && param.(param_set).Lout~=0 && abs(heuristic_params(3))>0 && abs(heuristic_params(2))>0
        Image_param.Lcontour=abs(heuristic_params(3))/abs(heuristic_params(2));
    elseif Image_param.Lcontour~=0 && param.(param_set).Lin~=0 && abs(heuristic_params(3))>0 && abs(heuristic_params(1))>0
        Image_param.Lcontour=abs(heuristic_params(3))/abs(heuristic_params(1));
    elseif Lcon_~=0 && ~isempty(Lcon_)
        Image_param.Lcontour=Lcon_;
        warning_perso('cannot set heuristic Lcontour, taking given value');
    else isempty(Lcon_)
        Image_param.Lcontour=0;
        warning_perso('cannot set heuristic Lcontour, use 0 since given value is empty');
    end
    
   macro_init_regul;
   macro_upate_sigma;
   info_perso(['Automatic heuristic params: Lin=' num2str(param.(param_set).Lin,'%g') ' Lout=' num2str(param.(param_set).Lout,'%g') ' Lcon=' num2str(Image_param.Lcontour,'%g')...
       ' kappa=' num2str(kap,'%g') ' sigma=' num2str(sig,'%g')]);
   heuristic_params=1;
   virtual_time_loop_optimizer(Image_param.lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
      text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
      antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
      shift,lambda,kappa,sigma_used,Image_param.lambdaOutside,c1,c2,timestep,Imagee,0,su,0,0,subcall,param_set);

    cumul=(abs(heuristic_params(1))+abs(heuristic_params(2))+abs(heuristic_params(3)))/(abs(heuristic_params(4))+abs(heuristic_params(5)));
    if isfinite(cumul)
        lambda_=0.01*cumul;
    elseif ~isempty(lambda__) && lambda__~=0
        lambda_=lambda__;
        warning_perso('cannot set heuristic lambda, taking given value');
    else isempty(lambda__)
        warning_perso('cannot set heuristic Lcontour, use 1 since given value is empty');
        lambda_=1;
    end
        
    
    
    macro_init_regul;
    macro_upate_sigma;
    info_perso([' lambda_=' num2str(lambda_,'%g')]);
    heuristic_params=0;
end
%% save initial contour in convergence tif
    if param.(param_set).save_level_set && param.(param_set).AC_method>=1000
        imwrite(uint16((Level_set_fct/200+0.5)*(2^16-1)),[Image_param.mov_name(1:(length(Image_param.mov_name)-4)) '_LSconv.tif'],'tif','WriteMode','append','compression',param.(param_set).compression_stack,'Description',param2str(param));
    end
    %% SAVE PARAMS BEFORE STARTING LOOP
if isempty(subcall) || ~subcall
%     save('-v7.3',[mat_name(1:(end-11)) '_all_vars.mat']);
    segmentation=cell(1,length(loop_array+1));
%     if param.AC_method>=1000
%         segmentationLS=cell(1,length(loop_array+1));
%     end
    if param.(param_set).reuse_initial_contour==1
            param.(param_set).reuse_initial_contour=2;
    end
end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% LOOP
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for f_real_t=2:1:(length(loop_array)+1)
%% initializing next loop
        real_t=round(f_real_t);
        t=real_t;
        number_of_reset_on_nan=param.(param_set).number_of_reset_on_nan_per_ite;
        update_optim_method;
%         if param.AC_method==0 || (first+real_t-2)<param.AC_method
%                 virtual_time_loop_kernel=@virtual_time_loop;
%         else
%                 virtual_time_loop_kernel=@virtual_time_loop_Tai_Yao;
%                 if ~Tai_Yao_init
%                     Tai_Yao_init=1;
%                     current_c1=c1;
%                     current_c2=c2;
%                 end
%         end
        macro_upate_sigma;
        
        old_su=0;
            
            
            

%% update image params            
            if real_t>2
                if param.(param_set).AC_method<1000
                     [c1,c2,recompute_c1_c2_mode]=Initialize_Image_params(recompute_c1_c2_mode,1,...
                        c1,c2,normalise,smoothing_for_region_values,imhist_nb,black_object,...
                        Cxm((shift+1):(Psize+shift+1),t),Cym((shift+1):(Psize+shift+1),t),Imagee_,real_t,param_set);
                else
                     [c1,c2,recompute_c1_c2_mode]=Initialize_Image_params(recompute_c1_c2_mode,1,...
                        c1,c2,normalise,smoothing_for_region_values,imhist_nb,black_object,...
                        [],[],Imagee_,real_t,param_set);                        
                end
            end % in case of real_t==2, it's already done in the header
 %% reading and preprocessing next frame       
        if (isempty(subcall) || ~subcall ) && (real_t>2 || decimate < 0) % if subcall, the calling code should have loaded the frame
            [Imagee,Imagee_]=read_with_preprocess(image_stem,format_image,padding,first+loop_array(real_t-1),number+first-1,phase_contrast_preprocess_span,param_set,mask_image,0,...
            adjust_image,filter_image,provided_image,kalman_image,imtophat_image,clahe_image,maskFromInitialization_image,c1,c2);
        end % in case of real_t==2, it's already done in the header
        if ~isempty(Imagee)
            if f_real_t>2 && param.(param_set).update_starting_shape
                Create_starting_shape(param.(param_set).Contour_update_mode,Psize,Tsize,shift,Cxm_init,Cym_init,first+loop_array(real_t-1),0,param_set);
            end        

%% update image params            
%             if real_t>2
%                 if param.(param_set).AC_method<1000
%                      [c1,c2,recompute_c1_c2_mode]=Initialize_Image_params(recompute_c1_c2_mode,1,...
%                         c1,c2,normalise,smoothing_for_region_values,imhist_nb,black_object,...
%                         Cxm((shift+1):(Psize+shift+1),t),Cym((shift+1):(Psize+shift+1),t),Imagee_,real_t,param_set);
%                 else
%                      [c1,c2,recompute_c1_c2_mode]=Initialize_Image_params(recompute_c1_c2_mode,1,...
%                         c1,c2,normalise,smoothing_for_region_values,imhist_nb,black_object,...
%                         [],[],Imagee_,real_t,param_set);                        
%                 end
%             end % in case of real_t==2, it's already done in the header
            if strcmp(param.(param_set).stop_condition, 'stop_condition_surface_SD')
                Image_param.norm_SD=symmetric_divergence(Imagee,Imagee,[],[],100);
            end
%% display initial contour for iteration            
            if param.(param_set).AC_method<1000
                if ~exist('fig3','var')
                    fig3=[];
                end
                fig3=clear_create_figure_perso(fig3);
                hold_perso off
                I=imadjust(Imagee_);
                imshow_perso(I);
    %             axis xy % very important for reprensenting in direct axes
                hold_perso on
                if real_t>2
                    plot_ij(Cxm((shift+1):(Psize+shift+1),t),Cym((shift+1):(Psize+shift+1),t),'-og');% t is updated only by the virtual_time_loop fct
                else
                    plot_ij(Cxm((shift+1):(Psize+shift+1),2),Cym((shift+1):(Psize+shift+1),2),'-og');
                end
                drawnow_perso;
                %% apply enlarging of shape
                  if enlarge_starting_shape~=1 && real_t>2
                      mx=mean(Cxm(:,t));
                      my=mean(Cym(:,t));
                      Cxm(:,t)=enlarge_starting_shape*(Cxm(:,t)-mx)+mx;
                      Cym(:,t)=enlarge_starting_shape*(Cym(:,t)-my)+my;
                  end
                  
            end
    %% solve the scheme       
        %%explicit scheme solving

             [Edl_total2,Cxm,Cym,dl0m_,no_final_energy,no_final_energy2,Ekappa_total,Esigma_total,Edl_total,...
                 tt,new_step_total,last_step_total,t,dx,dxx,dxxx,dxxxx,dy,dyy,dyyy,dyyyy,ddl0m,su,old_su,res,Ein_total,Eout_total,Econ]=...
            virtual_time_loop_optimizer(Image_param.lambdaInside,area_diff_stop,max_iter,small_step_limit,display_every_n,energy_every_n,...
            text_each_ite,check_area_every,Psize,extensionmax,resample_each,Cxm,Cym,dl0m,no_final_energy,no_final_energy2,...
            antidivergence,evol_eq_sign,last_disp_Cxm,last_disp_Cym,adaptative_new_step,...
            shift,lambda,kappa,sigma_used,Image_param.lambdaOutside,c1,c2,timestep,Imagee,real_t,su,old_su,t,subcall,param_set);
            if length(heuristic_params)>1 || (~isempty(subcall) && subcall) % we run preliminary params tuning or Xu and Wand as initialization
                close_perso(fig3);
                return;
            end
            if ~isfield(param.(param_set),'fixed_length') || isempty(param.(param_set).fixed_length)
                dl0m=dl0m_;
            end
% previous procedure will overwrite the initial form with the new one.
% Moreover t is not indexing the time but the minimization iteration
% (virtual time)
        if no_final_energy2_
            no_final_energy2=1;
        end
    %% display, energy etc ...
            if ((tt>=3) && res>=0) % here we save also images when the detection was stopped by maxIter
                last_detection_succeeded =1; % we consider success even if stopped by maxIter
                if ~(isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java)
                    fig4=figure;
                    set(fig4,'PaperUnits','centimeters');
                    set(fig4,'PaperPosition',[1 1 20 20]);
                    hold_perso off
                    if param.(param_set).AC_method>=1000
                        plot_current_level_set(tt);
                    else
                        contour_plotter;
                    end
                    if ~isfield(param.(param_set),'presentation_movie_no_text') || isempty(param.(param_set).presentation_movie_no_text) || ~param.(param_set).presentation_movie_no_text
                        if res<10
                            if ty == 0
                                text(10,10,{['NON-OPTIMAL Image_file_number=' num2str(first+loop_array(real_t-1),'%d') ' Tai-Yao ite=' num2str(ty,'%d')]...
                                [' c_in=' num2str(c1,'%g') ' c_out=' num2str(c2,'%g')]},...
                                'color','m','fontsize',12,'FontWeight','Bold',...
                                'interpreter','none','VerticalAlignment','Top','HorizontalAlignment','Left');
                            else
                                text(10,10,{['NON-OPTIMAL Image_file_number=' num2str(first+loop_array(real_t-1),'%d') ' Tai-Yao ite=' num2str(ty,'%d')]...
                                [' c_in=' num2str(current_c1,'%g') ' c_out=' num2str(current_c2,'%g')]},...
                                'color','m','fontsize',12,'FontWeight','Bold',...
                                'interpreter','none','VerticalAlignment','Top','HorizontalAlignment','Left');
                            end
                        else
                            if ty == 0
                                text(10,10,{['Image_file_number=' num2str(first+loop_array(real_t-1),'%d') ' Tai-Yao ite=' num2str(ty,'%d')]...
                                [' c_in=' num2str(c1,'%g') ' c_out=' num2str(c2,'%g')]},...
                                'color','m','fontsize',12,'FontWeight','Bold',...
                                'interpreter','none','VerticalAlignment','Top','HorizontalAlignment','Left');
                            else
                                text(10,10,{['Image_file_number=' num2str(first+loop_array(real_t-1),'%d') ' Tai-Yao ite=' num2str(ty,'%d')]...
                                [' c_in=' num2str(current_c1,'%g') ' c_out=' num2str(current_c2,'%g')]},...
                                'color','m','fontsize',12,'FontWeight','Bold',...
                                'interpreter','none','VerticalAlignment','Top','HorizontalAlignment','Left');
                            end
                        end
                    end
                else
                    fig4=[];
                end
%                if (no_final_energy==0)
%                     [Ekappa,Esigma,Edl]=mathematica_generated_energy(Cxm((1+shift):(Psize+shift),t)',dx((1+shift):(Psize+shift)),dxx((1+shift):(Psize+shift)),dxxx((1+shift):(Psize+shift)),dxxxx((1+shift):(Psize+shift)),Cym((1+shift):(Psize+shift),t)',dy((1+shift):(Psize+shift)),dyy((1+shift):(Psize+shift)),dyyy((1+shift):(Psize+shift)),dyyyy((1+shift):(Psize+shift)),dl0m((1+shift):(Psize+shift)),ddl0m((1+shift):(Psize+shift)),lambda,kappa,sigma_used,extensionmax,lambdaInside,lambdaOutside,c1,c2);
%                     [dum1,dum2,Eout]=mathematica_generated_energy(Cxm((1+shift):(Psize+shift),t)',dx((1+shift):(Psize+shift)),dxx((1+shift):(Psize+shift)),dxxx((1+shift):(Psize+shift)),dxxxx((1+shift):(Psize+shift)),Cym((1+shift):(Psize+shift),t)',dy((1+shift):(Psize+shift)),dyy((1+shift):(Psize+shift)),dyyy((1+shift):(Psize+shift)),dyyyy((1+shift):(Psize+shift)),dl0m((1+shift):(Psize+shift)),ddl0m((1+shift):(Psize+shift)),lambda,kappa,sigma_used,extensionmax,0,lambdaOutside,c1,c2);
%                     Ekappa_total=sum(Ekappa); Esigma_total=sum(Esigma); Edl_total=sum(Edl); Eout_total=sum(Eout);
%                     message=sprintf('   ---> image #%d t=%d Ekappa=%g Esigma=%g Edl=%g Eout=%g',real_t,tt,Ekappa_total,Esigma_total,Edl_total,Eout_total);
%                     disp(message);
%                elseif no_final_energy_==0
%                    no_final_energy=0; % removed on 26th nov 08
%                end
                dati=strrep(datestr(now),':','-');
                if (final_fig_save) && (isempty(subcall) || ~subcall )
                    image_name=mat_name(1:(end-11));
%                     fig_desc=sprintf('%s__%s__timestep=%5.5e__c1=%5.5e__c2=%5.5e__lambdaInside=%5.5e__lambdaOutside=%5.5e__kappa=%5.5e__sigma_used=%5.5e__lambda=%5.5e__Psize=%d__Memory=%d__real_t=%d__.tif',image_name,datestr(now),timestep,current_c1,current_c2,Image_param.lambdaInside,Image_param.lambdaOutside,kappa,sigma_used,lambda/Image_param.resolution,Psize,memory,real_t);
%                     [pathstr0, name0] = fileparts(image_name);
                    fig_name=[mat_name(1:(end-11)) 'result.fig'];
                    fig_name2=[mat_name(1:(end-11)) 'result.jpg'];
                    log_name=[mat_name(1:(end-11)) 'result.log'];
                    if ~(isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java)
                        saveas_perso(fig4,fig_name,'fig');
                        saveFigAsTif(fig4,fig_name,'Description',param2str(param));
                    end
%                     temp=imread(fig_name);
%                     imwrite(temp,fig_name2,'jpg','Comment','Description',param2str(param));
%                     delete(fig_name);

                    fp=fopen(log_name,'w');
                    fprintf(fp,'========================= Settings =========================\n%s\n',param2str(param));
                    fclose_perso(fp);
                end
                if (no_final_energy~=0)
                    message=sprintf('   ---> image #%d t=%d Ekappa=%g Esigma=%g Edl=%g',real_t,tt,Ekappa_total,Esigma_total,Edl_total);
                end

%                 if res>0 % already above
                if param.(param_set).AC_method<1000 && res>=10
                    if (isempty(no_save_con) || ~no_save_con && (isempty(subcall) || ~subcall ))
                        fp=fopen(con_name,'a');
                        fprintf(fp,'\n%14.6f\t%d\n\n',(real_t+1)/frame_rate,Psize);
                        tmp_tmp=uint16(round(10*Cxm((shift+1):(shift+Psize),t+1)));
                        tmp_tmp(:,2)=uint16(round(10*Cym((shift+1):(shift+Psize),t+1)));
                        fprintf(fp,'%d\t%d\n',tmp_tmp(:,1:2)');
                        fclose_perso(fp);
                    else
                        saveFigAsTif(fig4,[con_name(1:(end-3)) 'tif'],'Description',param2str(param));
                    end
                end
                if con_movie && (isempty(no_save_con) || ~no_save_con) && ~presentation_movie && (isempty(subcall) || ~subcall )
                    if ~init_movie_
                        init_movie2(mov_name,fig4);
                        init_movie_=1;
                    end
                    MakeQTMovie('addfigurejp2',fig4);
                end
%                 end
                if nargout>=2
                    if res>=10 && param.(param_set).AC_method<1000
                        Cxm_(1:Psize,t+1)=Cxm((shift+1):(shift+Psize),t+1);
                        Cxm_init = Cxm_(1:Psize,t+1);
                        Cym_(1:Psize,t+1)=Cym((shift+1):(shift+Psize),t+1);
                        Cym_init = Cym_(1:Psize,t+1);
                    else
                        Cxm_(1:Psize,t+1)=nan(Psize,1);
                        Cym_(1:Psize,t+1)=nan(Psize,1);
                    end
                end
                if param.(param_set).AC_method<1000
                    result_contour=cat(2,Cxm((shift+1):(shift+Psize),t+1),Cym((shift+1):(shift+Psize),t+1));
                    if (initialization_mask == 1)
                        firstContours_backup(:,1,real_t-1) = result_contour(:,1);
                        firstContours_backup(:,2,real_t-1) = result_contour(:,2);
                    end
                end
                if (nargout <3) || ( ~isempty(force_close_fig) && force_close_fig)
                    close_perso(fig4);
                end
                % %%update reference shape
                if (~isfield(param.(param_set),'fixed_length') || isempty(param.(param_set).fixed_length)) && param.(param_set).AC_method<1000 && res>=10
                    temp=sqrt(dx((shift+1):(Psize+shift)).^2+dy((shift+1):(Psize+shift)).^2);
                    if (real_t==2) || ~exist('Memory','var') || isempty(Memory) || Memory <=0
                        dl0m((shift+1):(Psize+shift))=temp;
                    else
                        dl0m((shift+1):(Psize+shift))=(Memory-1)/Memory*dl0m((shift+1):(Psize+shift))+1/Memory*temp;
                    end
                    dl0m(1:shift)=dl0m((Psize+1):(Psize+shift));
                    dl0m((Psize+shift+1):(Psize+2*shift))=dl0m((shift+1):(2*shift));
                end
            else
                last_detection_succeeded =0;
            end
            
            Ekappa_total=nan;
            Esigma_total=nan;
            Edl_total=nan;
            Ein_total=nan;
            Eout_total=nan;
            Econ=nan;
            
           if (no_final_energy==0) && (isempty(subcall) || ~subcall ) && res>=10
                try
                    [Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Econ]=...
                        energy_framework(Cxm,dx,dxx,...
                        dxxx,dxxxx,Cym,...
                        dy,dyy,dyyy,...
                        dyyyy,dl0m,ddl0m,...
                        t,lambda,kappa,sigma_used,extensionmax,Image_param.lambdaInside,Image_param.lambdaOutside,c1,c2,param_set);
%                     Ekappa_total=sum(Ekappa); Esigma_total=sum(Esigma); Edl_total=sum(Edl); Eout_total=sum(Eout);
                    message=sprintf('   ---> image #%d t=%d Ekappa=%g Esigma=%g Edl=%g Ein=%g Eout=%g Econ=%g',real_t,tt,Ekappa_total,Esigma_total,Edl_total,Ein_total,Eout_total,Econ);
                    disp(message);
                catch error_
                   warning_perso('Failed to compute energy\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                end
           elseif no_final_energy_==0
               no_final_energy=0; % removed on 26th nov 08
           end
            
        end % test empty frame
    if (isempty(subcall) || ~subcall )
        try
            if res>=10
                segmentation{real_t-1}.Image_index=first+loop_array(real_t-1);
                segmentation{real_t-1}.Image_size=size(Imagee);
                 segmentation{real_t-1}.param=xmlToString(write_replace_entry([],[],'param',param));
                 segmentation{real_t-1}.param_set = param_set;
                 segmentation{real_t-1}.Image_param=xmlToString(write_replace_entry([],[],'Image_param',Image_param));
                 segmentation{real_t-1}.Ekappa_total=Ekappa_total;
                 segmentation{real_t-1}.Esigma_total=Esigma_total;
                 segmentation{real_t-1}.Edl_total=Edl_total;
                 segmentation{real_t-1}.Ein_total=Ein_total;
                 segmentation{real_t-1}.Eout_total=Eout_total;
                 segmentation{real_t-1}.Econ=Econ;
                 % fix for the issue saving function handle
%                  list_field=fieldnames(segmentation{real_t-1}.param);
%                  for ijk=1:length(list_field)
%                      if isa(segmentation{real_t-1}.param.(list_field{ijk}),'function_handle')
%                          segmentation{real_t-1}.param.(list_field{ijk})=func2str(segmentation{real_t-1}.param.(list_field{ijk}));
%                      end
%                  end
%                  list_field=fieldnames(segmentation{real_t-1}.Image_param);
%                  for ijk=1:length(list_field)
%                      if isa(segmentation{real_t-1}.Image_param.(list_field{ijk}),'function_handle')
%                          segmentation{real_t-1}.Image_param.(list_field{ijk})=func2str(segmentation{real_t-1}.Image_param.(list_field{ijk}));
%                      end
%                  end
                 %
                 
                if param.(param_set).AC_method>=1000
                    segmentation{real_t-1}.Contour=[];
                    segmentation{real_t-1}.Level_set=Level_set_fct;
                    Level_Set_All(:,:,real_t-1) = Level_set_fct;
                    imwrite(uint16((Level_set_fct/200+0.5)*(2^16-1)),[Image_param.mov_name(1:(length(Image_param.mov_name)-4)) '_LS.tif'],'tif','WriteMode','append','compression',param.(param_set).compression_stack,'Description',param2str(param));
                else
                    segmentation{real_t-1}.Contour=result_contour;
                    segmentation{real_t-1}.Level_set=[];
                end
            else
                warning_perso('CONVERGENCE FAILED');
                segmentation{real_t-1}.Contour='convergence failed';
                segmentation{real_t-1}.Level_set='convergence failed';
                if param.(param_set).AC_method>=1000
                    imwrite(uint16(zeros(size(Level_set_fct))),[Image_param.mov_name(1:(length(Image_param.mov_name)-4)) '_LS.tif'],'tif','WriteMode','append','compression',param.(param_set).compression_stack,'Description',param2str(param));
                    Level_Set_All(:,:,real_t-1) = nan(size(Level_set_fct));
                end
            end
        catch error_
           warning_perso('Catch error in saving segmentation \n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
            segmentation{real_t-1}.Contour='error';
            segmentation{real_t-1}.Level_set='error';
%             segmentationLS{real_t-1}.Image_index='error';
        end
%         save('-v7.3',[con_name(1:(length(con_name)-4)) '.result.mat'],'segmentation');
        save([con_name(1:(length(con_name)-4)) '.result.mat'],'segmentation');
 %       if ~isempty(pathMainDirectory)
 %           name_segmentation = [con_name(1:(length(con_name)-4)) '.result.mat'];
%            save(fullfile(pathMainDirectory,name_segmentation),'segmentation');
%        end
        if ty == 0
            disp(['-->DONE Image_file_number=' num2str(first+loop_array(real_t-1),'%d') ' Tai-Yao ite=' num2str(ty,'%d') ...
                        ' c_in=' num2str(c1,'%g') ' c_out=' num2str(c2,'%g')]);
        else
            disp(['-->DONE Image_file_number=' num2str(first+loop_array(real_t-1),'%d') ' Tai-Yao ite=' num2str(ty,'%d') ...
                        ' c_in=' num2str(current_c1,'%g') ' c_out=' num2str(current_c2,'%g')]);
        end
    else
        if ty == 0
            disp(['-->DONE INITIALIZATION Image_file_number=' num2str(first+loop_array(real_t-1),'%d') ' Tai-Yao ite=' num2str(ty,'%d') ...
                        ' c_in=' num2str(c1,'%g') ' c_out=' num2str(c2,'%g')]);
        else
            disp(['-->DONE INITIALIZATION Image_file_number=' num2str(first+loop_array(real_t-1),'%d') ' Tai-Yao ite=' num2str(ty,'%d') ...
                        ' c_in=' num2str(current_c1,'%g') ' c_out=' num2str(current_c2,'%g')]);
        end
    end
    % rewrite on purpose updated sturcture at each iteration in case of bug
    
    if isempty(subcall) || ~subcall
        if param.(param_set).save_level_set && param.(param_set).AC_method>=1000
            imwrite(uint16((Level_set_fct/200+0.5)*(2^16-1)),[Image_param.mov_name(1:(length(Image_param.mov_name)-4)) '_FIN.tif'],'tif','WriteMode','append','compression',param.(param_set).compression_stack,'Description',[' == param == ' sprintf('n') param2str(param) sprintf('\n\n') ' == Image_param == ' sprintf('n') param2str(Image_param)]);
        end
    end
    
    if exist('fig_LS','var') && ~isempty(fig_LS) && ishandle(fig_LS)
%                         figure_perso(fig_LS);
        close_perso(fig_LS);
    end
    
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% end loop in time
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (isempty(subcall) || ~subcall )
        if (isempty(no_save_con) || ~no_save_con) && param.(param_set).AC_method<1000
            fp=fopen(con_name,'a');
            fprintf(fp,'\n%14.6f\t%d\n',9999.99,9999);
            fclose_perso(fp);
        end

        if con_movie && (isempty(no_save_con) || ~no_save_con)
            finish_movie;
        end
    end
    if ~(isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java) && exist('fig3','var') && exist('fig3','var') && ishandle(fig3)
        close_perso(fig3); %to prevent instability pointed out by Khaled
    end
end