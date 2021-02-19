function [maskedStack] = from_contour_to_mask( segmentation,imageStack_raw,rectangular_mask)

%enable to convert the contour position into a mask for each frame  and to
%superpose this mask on the original picture

global general_param;
global param

%%

imageRef =imcrop(imageStack_raw(:,:,1),rectangular_mask);

%% 

nbContours = size(segmentation,2);

% see labboook 12, page 51

if param.landing_analysis == 1
    if param.channel_total > 1
        num_images = round ( size(imageStack_raw,3) /param.channel_total );
    else
        num_images = size(imageStack_raw,3);
    end
elseif param.landing_analysis == 0
    num_images = size(imageStack_raw,3);
end

if param.cortex_pass2.decimate ~= 1 && param.landing_analysis == 1
    loop_array=0:param.cortex_pass2.decimate:(param.sp3-param.sp2);
end

%nbContours = num_images; % required for C. brissae
if param.cortex_pass2.decimate == param.decimate
    if (nbContours == num_images)
        disp('good agreement between active contour number and video image number');
    else
        error('mismatch in contours number and images number');
    end
    maskedStack = zeros(size(imageRef,1),size(imageRef,2),nbContours);
else
    if param.landing_analysis == 0 && (nbContours == num_images)
        disp('good agreement between active contour number and video image number');
    elseif param.landing_analysis == 1 && (nbContours == length(loop_array))  
        disp('good agreement between active contour number and video image number');
    else
        error('mismatch in contours number and images number');
    end 
    maskedStack = zeros(size(imageRef,1),size(imageRef,2),num_images);   
end

%%
    
if param.cortex_pass2.decimate == param.decimate
    for i = 1: nbContours
        X = transpose(segmentation{1,i}.Contour(:,1));
        Y = transpose(segmentation{1,i}.Contour(:,2));
        mask = poly2mask(Y,X,size(imageRef,1),size(imageRef,2));
        maskedStack(:,:,i) = logical(mask);
    end
else
    if param.landing_analysis == 1
        loop_array=0:param.cortex_pass2.decimate/param.decimate:num_images-1;
        for i = 1:1:length(loop_array)
            X = transpose(segmentation{1,i}.Contour(:,1));
            Y = transpose(segmentation{1,i}.Contour(:,2));
            mask = poly2mask(Y,X,size(imageRef,1),size(imageRef,2));
            for j = 1 : param.cortex_pass2.decimate / param.decimate
                if ( loop_array(i)+ j) <= num_images
                    maskedStack(:,:,loop_array(i)+ j) = logical(mask);
                else
                    break
                end
            end
        end
    else
        for i = 1:1:num_images
            X = transpose(segmentation{1,i}.Contour(:,1));
            Y = transpose(segmentation{1,i}.Contour(:,2));
            mask = poly2mask(Y,X,size(imageRef,1),size(imageRef,2));     
            maskedStack(:,:,i) = logical(mask);
        end       
    end
end

clear imageRef
clear nbContours
clear num_images
clear mask
clear X
clear Y

end
