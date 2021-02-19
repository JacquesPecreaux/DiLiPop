function [furrow_position]=get_furrow_position...
    (xCoordinate_cytokinesis_furrow,percentLength_cytokinesis_furrow,furrow_detection_convexity,pathDirectory_validation)


% just average on any case on a number of frames depending on frequency

global param;
global pathMainDirectory;
global general_param

if nargin < 4
    pathDirectory_validation = pathMainDirectory;
end

if param.landing_analysis == 0
    image_start_furrow_detection = round( (furrow_detection_convexity.image_detection - param.sp2) /param.cortex_pass2.decimate); % image nb within the reduced image stack
else
    image_start_furrow_detection = furrow_detection_convexity.image_detection - param.sp2; % image from the 0 of analysis (sp2)
end


%% window averaging of furrow position

if param.sp6 >=5
    
    furrow_position.window_averaging = 1;
    for k = 1 : (size(xCoordinate_cytokinesis_furrow,1) - general_param.furrow_detection.size_averaging)
        xCoordinate_cytokinesis_furrow_final(k,1) = ...
            nanmean(xCoordinate_cytokinesis_furrow(k:k+general_param.furrow_detection.size_averaging,1));
        percentLength_cytokinesis_furrow_final(k,1) = ...
            nanmean(percentLength_cytokinesis_furrow(k:k+general_param.furrow_detection.size_averaging,1));
    end

    % add averaging at the end
    length = size(xCoordinate_cytokinesis_furrow,1);
    for i = 1 : general_param.furrow_detection.size_averaging
        xCoordinate_cytokinesis_furrow_final(length+1-i) = ...
            xCoordinate_cytokinesis_furrow_final(length - general_param.furrow_detection.size_averaging );
        percentLength_cytokinesis_furrow_final(length+1-i) = ...
            percentLength_cytokinesis_furrow_final(length - general_param.furrow_detection.size_averaging );
    end

else   

    furrow_position.window_averaging = 0;
    for k = 1 : (size(xCoordinate_cytokinesis_furrow,1))
        xCoordinate_cytokinesis_furrow_final(k,1) = xCoordinate_cytokinesis_furrow(k,1);
        percentLength_cytokinesis_furrow_final(k,1) = percentLength_cytokinesis_furrow(k,1);
    end

end
   
    %% mean value of furrow position

if ~isnan( image_start_furrow_detection)
    percentLength_cytokinesis_furrow_mean = nanmean(percentLength_cytokinesis_furrow(image_start_furrow_detection:end));
    xCoordinate_cytokinesis_furrow_mean = nanmean(xCoordinate_cytokinesis_furrow(image_start_furrow_detection:end));       
    if isnan( percentLength_cytokinesis_furrow_mean)
        if param.sp6 >=5 && param.cortex_pass2.decimate == 1 || ( param.sp6 >=5 && param.cortex_pass2.decimate  ~= 1 && param.landing_analysis == 1 )
            nb_last_images = general_param.furrow_detection.nb_last_images_for_mean * 10;
        else
            nb_last_images = general_param.furrow_detection.nb_last_images_for_mean;
        end
        percentLength_cytokinesis_furrow_mean = nanmean(percentLength_cytokinesis_furrow(end-nb_last_images:end));
        xCoordinate_cytokinesis_furrow_mean = nanmean(xCoordinate_cytokinesis_furrow(end-nb_last_images:end));
    end
else
    if param.sp6 >=5 && param.cortex_pass2.decimate == 1 || ( param.sp6 >=5 && param.cortex_pass2.decimate  ~= 1 && param.landing_analysis == 1 )
        nb_last_images = general_param.furrow_detection.nb_last_images_for_mean * 10;
    else
        nb_last_images = general_param.furrow_detection.nb_last_images_for_mean;
    end
    percentLength_cytokinesis_furrow_mean = nanmean(percentLength_cytokinesis_furrow(end-nb_last_images:end));
    xCoordinate_cytokinesis_furrow_mean = nanmean(xCoordinate_cytokinesis_furrow(end-nb_last_images:end));
end


    %% assign values for position of furrow before detection of furrow

if ~isnan( image_start_furrow_detection)  
    for i = 1 : floor(image_start_furrow_detection/param.decimate)
            xCoordinate_cytokinesis_furrow_final(i) = xCoordinate_cytokinesis_furrow_mean; 
            percentLength_cytokinesis_furrow_final(i) = percentLength_cytokinesis_furrow_mean; %or better to set to 50%??
    end
    for i = 1 : size(xCoordinate_cytokinesis_furrow_final,1)
        if isnan(xCoordinate_cytokinesis_furrow_final(i,1))
            xCoordinate_cytokinesis_furrow_final(i) = xCoordinate_cytokinesis_furrow_mean;
            percentLength_cytokinesis_furrow_final(i) = percentLength_cytokinesis_furrow_mean;
        end
    end   
    if isnan(percentLength_cytokinesis_furrow_mean)
        furrow_position.detection = 0;
    else
        furrow_position.detection = 1;
    end
    furrow_position.percent_length.rawData = percentLength_cytokinesis_furrow;
    furrow_position.percent_length.timeDependence = percentLength_cytokinesis_furrow_final;
    furrow_position.percent_length.mean = percentLength_cytokinesis_furrow_mean;
    furrow_position.xCoordinate.rawData = xCoordinate_cytokinesis_furrow;
    furrow_position.xCoordinate.timeDependence = xCoordinate_cytokinesis_furrow_final;
    furrow_position.xCoordinate.mean = xCoordinate_cytokinesis_furrow_mean;
    furrow_position.image_start_detection = furrow_detection_convexity.image_detection;
    furrow_position.limit_min_curvature = general_param.furrow_detection.limit_min_curvature; 
    if strcmp(general_param.furrow_detection.place,'cortex')
        furrow_position.limit_convex_ratio = general_param.furrow_detection.limit_convex_ratio_cortex;
        furrow_position.max_nb_large_convexity = general_param.furrow_detection.max_nb_large_convexity_cortex;
    elseif strcmp(general_param.furrow_detection.place,'midPlane')
        furrow_position.limit_convex_ratio = general_param.furrow_detection.limit_convex_ratio_midPlane;
        furrow_position.max_nb_large_convexity = general_param.furrow_detection.max_nb_large_convexity_midPlane;
    end
else        
    for i = 1 : size(xCoordinate_cytokinesis_furrow_final,1)
        if isnan(xCoordinate_cytokinesis_furrow_final(i,1))
            xCoordinate_cytokinesis_furrow_final(i) = xCoordinate_cytokinesis_furrow_mean;
            percentLength_cytokinesis_furrow_final(i) = percentLength_cytokinesis_furrow_mean;
        end
    end   
    furrow_position.detection = 0;
    furrow_position.percent_length.rawData = percentLength_cytokinesis_furrow;
    furrow_position.percent_length.timeDependence = percentLength_cytokinesis_furrow_final;
    furrow_position.percent_length.mean = percentLength_cytokinesis_furrow_mean;
    furrow_position.xCoordinate.rawData = xCoordinate_cytokinesis_furrow;
    furrow_position.xCoordinate.timeDependence = xCoordinate_cytokinesis_furrow_final;
    furrow_position.xCoordinate.mean = xCoordinate_cytokinesis_furrow_mean;
    furrow_position.image_start_detection = NaN;
    furrow_position.limit_min_curvature = general_param.furrow_detection.limit_min_curvature;
    if strcmp(general_param.furrow_detection.place,'cortex')
        furrow_position.limit_convex_ratio = general_param.furrow_detection.limit_convex_ratio_cortex;
        furrow_position.max_nb_large_convexity = general_param.furrow_detection.max_nb_large_convexity_cortex;
    elseif strcmp(general_param.furrow_detection.place,'midPlane')
        furrow_position.limit_convex_ratio = general_param.furrow_detection.limit_convex_ratio_midPlane;
        furrow_position.max_nb_large_convexity = general_param.furrow_detection.max_nb_large_convexity_midPlane;
    end
end
    
    
%% plot

if param.channel_total > 1
    time = transpose(1/param.sp6*[param.sp2 : param.channel_total  : param.sp3]);
else
if param.landing_analysis == 1
   % time = transpose(1/param.sp6*[param.sp2 : 1 : size(xCoordinate_cytokinesis_furrow_final,1)+param.sp2-1]);
   time = transpose(1/param.sp6*[param.sp2 : param.decimate : param.sp3]);
elseif param.landing_analysis == 0
    time = transpose(1/param.sp6*[param.sp2 : param.cortex_pass2.decimate : param.sp3]);    
end
end
furrow_position.time_vector = time;

figure

subplot(2,1,1);
%plot(time,percentLength_cytokinesis_furrow(1: size(time,1)) ); % for C. briggsae
plot(time,percentLength_cytokinesis_furrow);
xlabel ('time in sec');
ylabel ('percent of embryo length');
title('Position of the furrow position in total embryo length with time (raw data) ');
if ~isnan(image_start_furrow_detection)
    string3 = num2str( round(furrow_detection_convexity.image_detection / param.sp6) ); % in sec from start of imaging/recording
    string5 = num2str( round(furrow_detection_convexity.image_detection) ); 
    string4 = ['start furrow detection = image ' string5 ' = ' string3 ' sec'];
    text(50,50,string4,'Units','pixels')
end

subplot(2,1,2);
%plot(time,percentLength_cytokinesis_furrow_final(1: size(time,1)) ); % for c. briggsae
plot(time,percentLength_cytokinesis_furrow_final);
xlabel ('time in sec');
ylabel ('percent of embryo length');
title('Position of the furrow position in total embryo length with time (final value)');
string1 = num2str( round(percentLength_cytokinesis_furrow_mean));
string2 = ['mean position of the furrow = ' string1 ' % of AP embryo length'];
text(50,50,string2,'Units','pixels')

figureName = strcat('furrowPosition_convexity-', short_name,  param.extra, '.fig');
saveas_perso(gcf,fullfile(pathMainDirectory,figureName));    
figureName2 = strcat('furrowPosition_convexity-', short_name,  param.extra, '.tif');
saveas_perso(gcf,fullfile(pathDirectory_validation,figureName2)); 
saveas_perso(gcf,fullfile(pathMainDirectory,figureName2)); 
close(gcf)


%% save data

name = strcat('furrow_position_convexity-', short_name,  param.extra, '.mat');
save(fullfile(pathMainDirectory,name), '-struct', 'furrow_position');


end
