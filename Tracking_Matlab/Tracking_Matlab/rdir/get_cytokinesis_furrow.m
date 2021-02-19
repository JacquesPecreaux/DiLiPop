
function [furrow_position]=get_cytokinesis_furrow(name_,maskedStack_rotated,regionXlimit,regionXlength,pathDirectory_validation)

global param;
global pathMainDirectory

%% get furrow detection start image using change in convexivity

if param.timing_key ~= 0
    [furrow_detection_convexity] = timing_cytokinesis_furrow(name_,maskedStack_rotated,pathDirectory_validation); % timing in image nb with 0 at start of recording
elseif param.timing_key == 0  
    furrow_detection_convexity.image_detection = param.furrow_detection_time * param.sp6;
    name = strcat('furrow_detection_convexity-', short_name,  param.extra, '.mat');
    save(fullfile(pathMainDirectory,name), '-struct', 'furrow_detection_convexity');
end


%% first try with usual curvature limit

[coordinates_minCurvature1,coordinates_minCurvature2,xCoordinate_furrow_2contours] = ...
    localize_minimum_curvature(maskedStack_rotated);

start_region_embryo = mean(regionXlimit.entireEmbryo.nbR10(:,1));
length_tenth_of_embryo = mean(regionXlength.entireEmbryo.nbR10(1,:));

for i = 1 : size(coordinates_minCurvature1,1)
     if coordinates_minCurvature1(i,1) < ( start_region_embryo + 9* length_tenth_of_embryo ) ...
             && coordinates_minCurvature1(i,1) > ( start_region_embryo + 3* length_tenth_of_embryo )
         coordinates_minCurvature1(i,:) = coordinates_minCurvature1(i,:);
     else
         coordinates_minCurvature1(i,:) = [NaN,NaN];
     end
     if coordinates_minCurvature2(i,1) < ( start_region_embryo + 9* length_tenth_of_embryo ) ...
             && coordinates_minCurvature2(i,1) > ( start_region_embryo + 3* length_tenth_of_embryo )
         coordinates_minCurvature2(i,:) = coordinates_minCurvature2(i,:);
     else
         coordinates_minCurvature2(i,:) = [NaN,NaN];
     end    
 end

percentLength_cytokinesis_furrow = NaN(size(coordinates_minCurvature1,1),1);

% below commented line that are necessary when trying to redo tracking on
% old movies because of delta time frame in sp2
% end_ = length(regionXlimit.entireEmbryo.nbR1);
% for i = 1 : 25
%     regionXlimit.entireEmbryo.nbR1(end_+i) = regionXlimit.entireEmbryo.nbR1(end_);
% end
% for i = 1 : 25
%     regionXlength.entireEmbryo.nbR1(end_+i) = regionXlength.entireEmbryo.nbR1(end_);
% end

for i = 1 : size(coordinates_minCurvature1,1)
    xCoordinate_cytokinesis_furrow_2(i,:)= cat(2,coordinates_minCurvature1(i,1),coordinates_minCurvature2(i,1));
    xCoordinate_cytokinesis_furrow(i,1) = nanmean(xCoordinate_cytokinesis_furrow_2(i,:),2);
    if ~isnan(xCoordinate_furrow_2contours(i,1))
        xCoordinate_cytokinesis_furrow(i,1) = xCoordinate_furrow_2contours(i,1);
    end
    if ~isnan(xCoordinate_cytokinesis_furrow(i,1))
          percentLength_cytokinesis_furrow(i,1) = ( xCoordinate_cytokinesis_furrow(i,1) - regionXlimit.entireEmbryo.nbR1(i,1) )/...
          (regionXlength.entireEmbryo.nbR1(1,i))*100;
    end
end


%%

 [furrow_position] = get_furrow_position...
    (xCoordinate_cytokinesis_furrow,percentLength_cytokinesis_furrow,furrow_detection_convexity,pathDirectory_validation);


end
