function [status2,segmentation] = perform_active_contours(imageStack_raw)

%to perform active contour on each image of the video
% this is done in two setps, to help identifying the good parameters.
% important parameters are :
%   - Lin (weight given to pixel inside), 
%   - Lout (weight given to pixel outise),
%   - kap: rigidity of the elastic
%   - sig: tension of the elastic
%   - clahe_cliplimit: to account for inhomogeneity

% to be able to validate the parameters, set param.cortex_pass1.visual_check_AC = 1

global param;
global current_c1;
global current_c2;
global mask_init;
global firstContours_backup;
global Imagee
global general_param;
global imageStack_kalman;

name = basename_builder;

% set first image as done in create_local_stack_cortex
first = param.sp2;


%% if kalman denoised pictures necessary for AC

if param.cortex_pass1.kalman_image == 1 || param.cortex_pass2.kalman_image == 1
    imageStack_kalman=Kalman_Stack_Filter...
        (imageStack_raw,general_param.cortex_analysis.kalman_gain,general_param.cortex_analysis.kalman_percentvar);
end


%% parameters for the first AC on a few first images (cortex_pass1)

firstContours_backup = zeros(param.cortex_pass1.Psize,2,param.cortex_pass1.number);

[status2,~] = explicit_2D_space_only_v0p2_no_t_p(name,param.sp7,first,param.cortex_pass1.number,param.format_image,param.cortex_pass1.kap,param.cortex_pass1.sig,param.cortex_pass1.black_object,param.cortex_pass1.timestep,...
    param.cortex_pass1.phase_contrast_preprocess_span,param.cortex_pass1.c1,param.cortex_pass1.c2,param.cortex_pass1.Lin,param.cortex_pass1.Lout,param.cortex_pass1.adjust_image,param.cortex_pass1.smoothing_for_region_values,...
    param.cortex_pass1.adaptative_new_step,param.cortex_pass1.absolute_lamba_X,param.cortex_pass1.normalise,param.cortex_pass1.imhist_nb,'cortex_pass1');
if status2 < 0
    error('initialization active contour (pass 1) failed');
end

if param.cortex_pass1.visual_check_AC == 1
    
    Lin_change = 0;
    Lout_change = 0;
    Clahe_cliplimit_change = 0;
    
    for i = 1 : 10
        
        adjust_AC_parameters = input ('Do you wish to adjust the AC parameters (Y = 1/N = 0): ','s');
        
        if adjust_AC_parameters == 1
            
            Lin = input_perso(['Do I change Lin value (previous value = ' num2str(param.cortex_pass1.Lin,'%d') ') '] );
            Lin_change = (Lin ~= param.cortex_pass1.Lin);
            if Lin_change == 1
                param.cortex_pass1.Lin = Lin;
            end
            
            Lout = input_perso(['Do I change Lout value (previous value = ' num2str(param.cortex_pass1.Lout,'%d') ') '] );
            Lout_change = (Lout ~= param.cortex_pass1.Lout);
            if Lout_change == 1
                param.cortex_pass1.Lout = Lout;
            end
            
            clahe_cliplimit = input_perso(['Do I change clahe cliplimit value (previous value = ' num2str(param.cortex_pass1.clahe_cliplimit,'%d') ') '] );
            clahe_cliplimit_change = (clahe_cliplimit ~= param.cortex_pass1.clahe_cliplimit);
            if clahe_cliplimit_change == 1
                param.cortex_pass1.clahe_cliplimit = clahe_cliplimit;
            end
            
            [status2,~] = explicit_2D_space_only_v0p2_no_t_p(name,param.sp7,first,param.cortex_pass1.number,param.format_image,param.cortex_pass1.kap,param.cortex_pass1.sig,param.cortex_pass1.black_object,param.cortex_pass1.timestep,...
                param.cortex_pass1.phase_contrast_preprocess_span,param.cortex_pass1.c1,param.cortex_pass1.c2,param.cortex_pass1.Lin,param.cortex_pass1.Lout,param.cortex_pass1.adjust_image,param.cortex_pass1.smoothing_for_region_values,...
                param.cortex_pass1.adaptative_new_step,param.cortex_pass1.absolute_lamba_X,param.cortex_pass1.normalise,param.cortex_pass1.imhist_nb,'cortex_pass1');
            if status2 < 0
                error('initialization active contour (pass 1) failed');
            end
            
        elseif adjust_AC_parameters == 0
            
            if Lin_change == 1
                param.cortex_pass2.Lin = param.cortex_pass2.Lin;
            end
            
            if Lout_change == 1
                param.cortex_pass2.Lout = param.cortex_pass2.Lin;
            end
            
            if clahe_cliplimit_change == 1
                param.cortex_pass2.clahe_cliplimit = param.cortex_pass1.clahe_cliplimit;
            end
            
            break
            
        end
        
    end
end

number = (param.sp3 - first) +1;

Imagee=read_with_preprocess(basename_builder,param.format_image,param.sp7,param.sp2,number+param.sp2-1,...
    param.cortex_pass1.phase_contrast_preprocess_span,'cortex_pass1',param.cortex_pass1.mask_image,1,...
    param.cortex_pass1.adjust_image,param.cortex_pass1.filter_image,basename_builder,param.cortex_pass1.kalman_image,...
    param.cortex_pass1.imtophat_image,param.cortex_pass1.clahe_image,param.cortex_pass1.maskFromInitialization_image);

if ( param.cortex_pass1.initialization_mask == 1)
    [mask_init] = create_initial_mask(firstContours_backup,param.cortex_pass1.number);
end


%% parameters for the second AC on all the frames selected by user (cortex_pass2)

param.cortex_pass2.c1 = current_c1;
param.cortex_pass2.c2 = current_c2;

% set number as in creta_local_stack_cortex
number = (param.sp3 - first) +1;

[status2, segmentation] = explicit_2D_space_only_v0p2_no_t_p(name,param.sp7,first,number,param.format_image,param.cortex_pass2.kap,param.cortex_pass2.sig,param.cortex_pass2.black_object,param.cortex_pass2.timestep,...
    param.cortex_pass2.phase_contrast_preprocess_span,param.cortex_pass2.c1,param.cortex_pass2.c2,param.cortex_pass2.Lin,param.cortex_pass2.Lout,param.cortex_pass2.adjust_image,param.cortex_pass2.smoothing_for_region_values,...
    param.cortex_pass2.adaptative_new_step,param.cortex_pass2.absolute_lamba_X,param.cortex_pass2.normalise,param.cortex_pass2.imhist_nb,'cortex_pass2');


end

