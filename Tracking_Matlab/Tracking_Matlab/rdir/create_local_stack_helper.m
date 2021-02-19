function [imageStack_raw, timings] = create_local_stack_helper(first,decimate,channel,mask,landing)
global param;

number = (param.sp3 - first) +1;
name_ = basename_builder;
[~,siz,fitsnom]=read_init(name_,param.format_image,param.format_image,first);


if landing == 1 % all images are required for Jaqaman analysis
    for f_real_t = 2:1:(number+1)
        [Imagee,~,error_reading]=read_with_trial(first+real_t-2,param.format_image,param.format_image,siz,fitsnom,'none',...
            param.sp3,channel,mask);  
        if error_reading || isempty(Imagee)
            error('JACQ:FAILREAD','fail to read the file');
        end
        if f_real_t == 2
            Imagee_ref = Imagee;
            imageStack_raw=nan([size(Imagee) number], 'single');
        end
        Imagee2 = mat2gray(Imagee,stretchlim(Imagee_ref,0));
        imageStack_raw (:,:,real_t - 1) = single(Imagee2);
    end   
    timings = (first+(2:1:(number+1))-2)/param.sp6; 
elseif landing == 0  % only contours evolution is necessary, so possible to skip images
    if decimate > 0
        loop_array=0:decimate:(number-1);
    else
        loop_array=(number-1):decimate:0;
    end
    for f_real_t = 2:1:(length(loop_array)+1)
        real_t=loop_array(f_real_t -1);
        [Imagee,~,error_reading]=read_with_trial(first+real_t,param.format_image,param.format_image,siz,fitsnom,'none',...
            param.sp3,channel,mask);
        if error_reading || isempty(Imagee)
            error('JACQ:FAILREAD','fail to read the file');
        end
        if f_real_t == 2
            Imagee_ref = Imagee;
            imageStack_raw=nan([size(Imagee) length(loop_array)], 'single');
        end
        
        Imagee2 = mat2gray(Imagee,stretchlim(Imagee_ref,0));
        imageStack_raw (:,:,round(f_real_t) - 1) = single(Imagee2);
    end
    timings = ( loop_array((2:1:(length(loop_array)+1))-1) )/param.sp6; 
end
end