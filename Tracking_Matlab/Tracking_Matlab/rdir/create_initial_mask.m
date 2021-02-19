function [mask_init] = create_initial_mask(firstContours_backup,number)
%create mask for embryo using contours obtained on a few first images

global param;
%global firstContours_backup;
global Imagee;


I_cropped = Imagee;
Image_size = size(I_cropped);

mask_init = zeros(Image_size(1,1),Image_size(1,2));

for i = 1 :number
    X = transpose(firstContours_backup(:,1,i));
    Y = transpose(firstContours_backup(:,2,i));
    mask = poly2mask(Y,X,Image_size(1,1),Image_size(1,2));
    mask_init = mask_init + mask;
    
end

mask_init = mask_init / number;

level = graythresh(mask_init);
mask_init = im2bw(mask_init,level);

se1 = strel('disk', param.cortex_pass1.diskSize_initMask);
mask_init = imdilate(mask_init, se1); 


end

