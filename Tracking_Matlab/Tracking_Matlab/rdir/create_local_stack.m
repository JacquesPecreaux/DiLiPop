% function create_local_stack
%
% % create a local stack of the images of interest of the embryo.
% %this is required for Kalman denoising on a stack. Take a few more images
% %before the first of interest (sp2) to have the best denoising

if param.landing_analysis == 1
    first = param.sp2-general_param.cortex_analysis.kalman_shift;
    if first <=0
        warning_perso('algorithm cannot analyze from the first frame since a few images are needed to initialize Kalman filter - correct to start as early as possible');
        first = 1;
    end
else
    first = param.sp2;
end

imageStack_raw = create_local_stack_helper(first,param.cortex_pass2.decimate,param.cortex_pass2.channel_interest_AC,...
    param.cortex_pass2.mask_image, param.landing_analysis);

