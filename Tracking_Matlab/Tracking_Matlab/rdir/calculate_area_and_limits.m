function [ regionXlimit,regionXlength,regionArea ] = calculate_area_and_limits( ImStackMasked_NaN_rotated,StackMasked_rotated )

%Get the area, length in X and X limits of the non-masked region
%of the embryo tiff files, for different numbers of regions of division
%along the AP axis

% all the different data are saved in a structure in a mat file, whose name
% is data-nameRecording.mat

global pathMainDirectory;
global general_param;
global param

num_images = size(ImStackMasked_NaN_rotated,3); 

%%
for iZone = 1:general_param.cortex_analysis.nbRegions

ext = num2str(iZone);
name = ['nbR' ext];
    
%allocate the area matrix
area = zeros(num_images,iZone);

%get the width and length in pixel of the image
sizeImage1=size(ImStackMasked_NaN_rotated(:,:,1));
%sizeImage1(1,1); %heigth in y axis, namely vertical
%sizeImage1(1,2); % width in x axis, namely horizontal

%for each picture of the stack
    for k =  1: num_images

    % initialize values of the x-window where embryo is to 0
    Xmin(k) = 0;
    Xmax(k) = 0;

    % find the Xmin value where embryo starts
        for iX = 1 : sizeImage1(1,2)
            column_isnan = [];
            sum_column_isnan = 0;
            column_isnan = ~isnan(ImStackMasked_NaN_rotated(:,iX,k));
            sum_column_isnan = sum(column_isnan(:));
            if (sum_column_isnan ~= 0)
                Xmin(k)=iX;
                break
            end
        end
        

    %find the Xmax value where embryo finishes
        for iX = sizeImage1(1,2) : -1  :1
            column_isnan = [];
            sum_column_isnan = 0;
            column_isnan = ~isnan(ImStackMasked_NaN_rotated(:,iX,k));
            sum_column_isnan = sum(column_isnan(:));
            if (sum_column_isnan ~= 0)
                Xmax(k)=iX;
                break
            end
        end

    %get the size in pixels of each region on X-axis
    deltaX(k) = (Xmax(k) - Xmin(k))/iZone;
 
    %for each region of the embryo
        for iiZone = 1 : iZone   
            xStart(k,iiZone) = Xmin(k) + (iiZone -1)*deltaX(k); % get the starting point in X-axis
            StackMaskedCrop = imcrop(StackMasked_rotated(:,:,k),[xStart(k,iiZone) 0 deltaX(k) sizeImage1(1,1)]); % crop the ROI
            area(k,iiZone)=bwarea(StackMaskedCrop); % calculate the area of the ROI
        end
    
    end


regionArea.entireEmbryo.(name)=area; % in pixels**2
regionXlimit.entireEmbryo.(name)=xStart;
regionXlength.entireEmbryo.(name)=deltaX;

end

if isempty(param.extra) || ( ~isempty(param.extra) && strcmp(param.extra,'__no_tag__') )
    nameData = strcat('regionArea-', short_name, '.mat');
else
    nameData = strcat('regionArea-', param.extra, short_name, '.mat');
end
save(fullfile(pathMainDirectory,nameData), '-struct', 'regionArea');

if isempty(param.extra) || ( ~isempty(param.extra) && strcmp(param.extra,'__no_tag__') )
    nameData3 = strcat('regionXlimit-', short_name, '.mat');
else
    nameData3 = strcat('regionXlimit-', param.extra, short_name, '.mat');
end
save(fullfile(pathMainDirectory,nameData3), '-struct', 'regionXlimit');

if isempty(param.extra) || ( ~isempty(param.extra) && strcmp(param.extra,'__no_tag__') )
    nameData4 = strcat('regionXlength-', short_name, '.mat');
else
    nameData4 = strcat('regionXlength-', param.extra, short_name, '.mat');
end
save(fullfile(pathMainDirectory,nameData4), '-struct', 'regionXlength');


end
