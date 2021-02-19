function [Imagee,Imagee_,mask_BW_cropped]=read_with_preprocess_core(format_image,padding,first,number,param_set,...
    mask_image,is_init,provided_image,kalman_image)
    global siz;
    global fitsnom;
    global param;
    global imageStack_kalman;
    global new_run_ri;
    global general_param
    persistent rectangular_mask;
    global mask_BW_AC


    if isempty(siz) && isempty(fitsnom) && ~is_init
        error('looks like you are updating contour to a second time on a sigle image passed to the code');
    end
    
    if ischar(provided_image) || (numel(provided_image) == 1 && isnan(provided_image))
        if is_init==1
             new_run_ri=1; %required for read_init
             image_stem = provided_image;
            [~,siz,fitsnom]=read_init(image_stem,format_image,padding,first,param.sp3,param_set);
        end
        [Imagee,~,error_reading]=read_with_trial(first,padding,format_image,siz,fitsnom,'AC_mask',param.sp3,param.(param_set).channel_interest_AC,mask_image);
        if error_reading || isempty(Imagee)
            error('JACQ:FAILREAD','fail to read the file');
        end
    else
        Imagee=provided_image;
    end
    Imagee_=Imagee;
    
    if (kalman_image == 1)
        
        if param.landing_analysis == 1 % image stack with all images number
            if param.sp2 > general_param.cortex_analysis.kalman_shift
                Imagee = imageStack_kalman(:,:,general_param.cortex_analysis.kalman_shift + (first - param.sp2 +1));
            else
                Imagee = imageStack_kalman(:,:,(first - param.sp2 +1));
            end
        else % image stack with image number every decimate      
            % first below is in images from start of the imaging with jump
            % of decimate
                first_ = floor( (first - param.sp2 ) /param.(param_set).decimate )+1; % new first value since kalman_stack have some skipped frames
                Imagee = imageStack_kalman(:,:,first_);            
        end
        
    end
    
    if is_init==1 &&( ~isempty(mask_image)  && ~isempty(mask_BW_AC) )  % no need to repeat at each iteration
        rectangular_mask = get_rectangular_mask(mask_BW_AC,Imagee);        
        mask_BW_cropped = imcrop(mask_BW_AC,rectangular_mask);
    elseif is_init==1 && (isempty(mask_image) && isempty(mask_BW_AC) )
        rectangular_mask = [1 1 512 512];
        mask_BW_cropped=[];
    else
        mask_BW_cropped=[];
    end
    
    Imagee= imcrop(Imagee,rectangular_mask);
    Imagee_= imcrop(Imagee_,rectangular_mask); % in case of Kalman filtering
    
end    
