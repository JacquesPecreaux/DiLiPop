
function [furrow_detection_convexity]=timing_cytokinesis_furrow(name_,maskedStack_rotated,pathDirectory_validation)

% use convexivity to detect furrow

global general_param;
global pathMainDirectory;
global param;
global mask_BW_AC
global Imagee

if nargin < 3
    pathDirectory_validation = pathMainDirectory;
end

if nargin<=1
    
    pathstr = getDatasetPath(param.stem_name, true);
    mainDirectory = 'contour detection';
    mkdir_perso(pathstr,mainDirectory);
    pathMainDirectory = strcat(pathstr , '/' , mainDirectory, '/');
    
    clear mainDirectory
    
    if ~isempty(param.default_extra)
        tag = param.default_extra;
    else
        tag = param.extra;
    end
    id = [name_((end-3):(end))];
    mat_name=[sprintf('%s%s_%s.%s',pathMainDirectory,id,tag,short_name) 'result.mat'];
    con_name=[mat_name(1:(end-11)) '.con'];
    mat_name_result=[con_name(1:(length(con_name)-4)) '.result.mat'];
    tmp = load(mat_name_result);
    segmentation = tmp.segmentation;
    FileInfo = dir(con_name);
    vector_datum = datevec(FileInfo.datenum);
    clear tmp
    clear mat_name
    
    create_local_stack;
    
    [~,siz,fitsnom]=read_init(basename_builder,param.format_image,param.sp7,param.sp2,param.sp3,'cortex_pass1');
    
    [Imagee,~,error_reading]=read_with_trial(param.sp2,param.format_image,param.format_image,siz,fitsnom,...
        'AC_mask',param.sp3,param.cortex_pass1.channel_interest_AC,param.cortex_pass1.mask_image);
    if error_reading || isempty(Imagee)
        error('JACQ:FAILREAD','fail to read the file');
    end
    
    if ~isempty(mask_BW_AC)
        if (vector_datum(1,1) >= 2014) && (vector_datum(1,2) >= 5)
            if (vector_datum(1,2) == 5)&& (vector_datum(1,3) <= 14)
                rectangular_mask = get_rectangular_mask_old(mask_BW_AC,Imagee);
            else
                rectangular_mask = get_rectangular_mask(mask_BW_AC,Imagee);
            end
        elseif (vector_datum(1,1) >= 2015)
            rectangular_mask = get_rectangular_mask(mask_BW_AC,Imagee);
        else
            rectangular_mask = get_rectangular_mask_old(mask_BW_AC,Imagee);
        end
    else
        rectangular_mask = [1 1 size(Imagee,1) size(Imagee,2)];
    end
    
    [ maskedStack] = from_contour_to_mask(segmentation,imageStack_raw,rectangular_mask);
    
    clear imageStack_raw
    clear rectangular_mask
    
    [ maskedStack_rotated ] = rotate_mask(maskedStack);
    clear maskedStack
    
end

mainDirectory = 'furrow_characterization';
pathMainDirectory = strcat(param.basepath , '/' , param.sp1 , '/' , mainDirectory, '/');

clear mainDirectory


ratio_brut = NaN(size(maskedStack_rotated,3),1);
start_cytokinesis_furrow = NaN;
inflection_point_convexity_ratio = NaN;

if strcmp(param.place,'cortex')
    limit_convex_ratio = general_param.furrow_detection.limit_convex_ratio_cortex;
    max_nb_large_convexity = general_param.furrow_detection.max_nb_large_convexity_cortex;
    image_studied_for_convex_ratio = general_param.furrow_detection.image_studied_for_convex_ratio_cortex;
    place = 'cortex';
elseif strcmp(param.place,'midPlane')
    limit_convex_ratio = general_param.furrow_detection.limit_convex_ratio_midPlane;
    max_nb_large_convexity = general_param.furrow_detection.max_nb_large_convexity_midPlane;
    image_studied_for_convex_ratio = general_param.furrow_detection.image_studied_for_convex_ratio_midPlane;
    place = 'midPlane';
end

if ( param.sp6 >=5 && param.cortex_pass2.decimate == 1 ) || ( param.sp6 >=5 && param.cortex_pass2.decimate  ~= 1 && param.landing_analysis == 1 )
    nb_last_images = general_param.furrow_detection.nb_last_images_for_mean * 10;
else
    nb_last_images = general_param.furrow_detection.nb_last_images_for_mean;
end

for ii_ = 1 : size(maskedStack_rotated,3)
    BW = maskedStack_rotated(:,:,ii_);
    STATS = regionprops(BW,'all');
   % disp(ii_);
    if length(STATS) >= 2
        ratio_brut(ii_) = limit_convex_ratio + 0.01;
    elseif(isempty(STATS))
        ratio_brut(ii_) = NaN;
    else
        ratio_brut(ii_) = STATS.ConvexArea /STATS.Area ;
    end
end

%notice pair number is required for windowsize
if ( param.sp6 >= 5 && param.cortex_pass2.decimate == 1 )  || ( param.sp6 >=5 && param.cortex_pass2.decimate  ~= 1 && param.landing_analysis == 1 )
    windowSize = 100;
else
    windowSize = 20; % 10 before
end

ratio_smooth_delayed = filter(ones(1,windowSize)/windowSize,1,ratio_brut);
%ratio_smooth(1:windowSize,1) = ratio_smooth(windowSize+1,1);
for i = windowSize/2 +1 : length(ratio_smooth_delayed)-windowSize/2
    ratio_smooth(i,1) = ratio_smooth_delayed(i+windowSize/2,1);
end
ratio_smooth(length(ratio_smooth_delayed)-windowSize/2+1:length(ratio_smooth_delayed),1) = ratio_smooth_delayed(length(ratio_smooth_delayed)-windowSize,1);
ratio_smooth(1:windowSize/2,1) = ratio_smooth_delayed(windowSize+1,1);

nb_large_convexity = 0;
nb_datavalleys = 0;
nb_datavalleys2 = 0;
nb_datavalleys3 = 0;
nb_datavalleys4 = 0;


if strcmp(place,'midPlane')
    
    %------------
    % strategy 1
    
    for i = size(ratio_smooth,1): -1 : round(size(ratio_smooth,1)*image_studied_for_convex_ratio)
        if (ratio_smooth(i) <= limit_convex_ratio)
            nb_large_convexity = nb_large_convexity +1;
            if nb_large_convexity == max_nb_large_convexity
                if param.landing_analysis == 1
                    start_cytokinesis_furrow = i; % OK?
                elseif param.landing_analysis == 0
                    start_cytokinesis_furrow = i*param.cortex_pass2.decimate; % to get it in image with number 1 set to param.sp2
                end
                break;
            end
        end
    end
    
    if isnan(start_cytokinesis_furrow)
        [C,I] = min(ratio_smooth(round(size(ratio_smooth,1)*image_studied_for_convex_ratio):size(ratio_smooth,1)));
        if param.landing_analysis == 1
            start_cytokinesis_furrow = size(ratio_smooth,1)-round(size(ratio_smooth,1)*image_studied_for_convex_ratio)+I-1;
        elseif param.landing_analysis == 0
            start_cytokinesis_furrow = ( size(ratio_smooth,1)-round(size(ratio_smooth,1)*image_studied_for_convex_ratio)+I-1 ) * param.cortex_pass2.decimate;
        end
    end
    
    start_cytokinesis_furrow = start_cytokinesis_furrow + param.sp2 -1; % to get it from the start of embryo recording
    
    %----------
    %strategy 2
    
    [datavalleys] = findinflections(ratio_smooth);
    
    for i = 1 : size(datavalleys,1)
        if ( datavalleys(i) > round(size(ratio_smooth,1)*image_studied_for_convex_ratio) ) && ...
                ( ratio_smooth(datavalleys(i)) >= limit_convex_ratio )
            nb_datavalleys=nb_datavalleys+1;
            ratio_datavalleys(nb_datavalleys) = ratio_smooth(datavalleys(i));
            if param.landing_analysis == 1
                image_datavalleys(nb_datavalleys)= datavalleys(i);
                image_datavalleys_raw(nb_datavalleys)= datavalleys(i);
            elseif param.landing_analysis == 0
                image_datavalleys(nb_datavalleys)= datavalleys(i) .* param.cortex_pass2.decimate;  % to get it in image with number 1 set to param.sp2
                image_datavalleys_raw(nb_datavalleys)= datavalleys(i);
            end
        end
    end
    
    if exist('ratio_datavalleys','var')
        [C_min,I_min] = min(ratio_datavalleys);
        inflection_point_convexity_ratio = image_datavalleys(I_min);  % in image with number 1 set to param.sp2
        
        if C_min > limit_convex_ratio +0.001
            inflection_point_convexity_ratio = NaN;
            for i = 1 : size(datavalleys,1)
                if ( ratio_smooth(datavalleys(i)) >= limit_convex_ratio -0.0015 ) && ...
                        ( ratio_smooth(datavalleys(i)) <= limit_convex_ratio + 0.001 ) && ...
                        ( datavalleys(i) > round(size(ratio_smooth,1)*image_studied_for_convex_ratio) )
                    nb_datavalleys2=nb_datavalleys2+1;
                    ratio_datavalleys2(nb_datavalleys2) = ratio_smooth(datavalleys(i));
                    if param.landing_analysis == 1
                        image_datavalleys2(nb_datavalleys2)= datavalleys(i);
                    elseif param.landing_analysis == 0
                        image_datavalleys2(nb_datavalleys2)= datavalleys(i) .* param.cortex_pass2.decimate;  % to get it in image with number 1 set to param.sp2
                    end
                end
            end
        end
        
        if exist('ratio_datavalleys2','var')
            [C_min2,I_min2] = min(ratio_datavalleys2);
            inflection_point_convexity_ratio = image_datavalleys2(I_min2);  % in image with number 1 set to param.sp2
        end
        
    else
        for j = 1 : size(datavalleys,1)
            if ( ratio_smooth(datavalleys(j)) >= limit_convex_ratio -0.001 ) && ...
                    ( ratio_smooth(datavalleys(j)) <= limit_convex_ratio +0.001 ) && ...
                    ( datavalleys(j) < 1.5*round(size(ratio_smooth,1)*image_studied_for_convex_ratio) )
                nb_datavalleys3=nb_datavalleys3+1;
                if param.landing_analysis == 1
                    image_datavalleys3(nb_datavalleys3)= datavalleys(j);
                elseif param.landing_analysis == 0
                    image_datavalleys3(nb_datavalleys3)= datavalleys(j) .* param.cortex_pass2.decimate;  % to get it in image with number 1 set to param.sp2
                end
            end
        end
        
        if exist('image_datavalleys3','var')
            [C_max,I_max] = max(image_datavalleys3);
            inflection_point_convexity_ratio = image_datavalleys3(I_max);  % in image with number 1 set to param.sp2
        end
        
    end
    
    if exist('ratio_datavalleys','var')
        index_start = find(datavalleys.* param.cortex_pass2.decimate == image_datavalleys(I_min));  % in image with number 1 set to param.sp2
        for j =  index_start : size(datavalleys,1)
            if ( ratio_smooth(datavalleys(j)) < C_min ) && ...
                    ( ratio_smooth(datavalleys(j)) >= limit_convex_ratio - 0.001 )
                nb_datavalleys4=nb_datavalleys4+1;
                ratio_datavalleys4(nb_datavalleys4) = ratio_smooth(datavalleys(j));
                if param.landing_analysis == 1
                    image_datavalleys4(nb_datavalleys4)= datavalleys(j);
                elseif param.landing_analysis == 0
                    image_datavalleys4(nb_datavalleys4)= datavalleys(j) .* param.cortex_pass2.decimate;  % to get it in image with number 1 set to param.sp2
                end
            end
        end
        if exist('ratio_datavalleys4','var')
            [C_min4,I_min4] = min(ratio_datavalleys4);
            inflection_point_convexity_ratio = image_datavalleys4(I_min4);  % in image with number 1 set to param.sp2
        end
    end
    
    if isnan(inflection_point_convexity_ratio)
        [C,I] = min(ratio_smooth(end-nb_last_images:end));
        if param.landing_analysis == 1
            inflection_point_convexity_ratio = ( size(ratio_smooth,1)-nb_last_images+I-1 );
        elseif param.landing_analysis == 0
            inflection_point_convexity_ratio = ( size(ratio_smooth,1)-nb_last_images+I-1 )* param.cortex_pass2.decimate ;  % to get it in image with number 1 set to param.sp2
        end
    end
    
    inflection_point_convexity_ratio = inflection_point_convexity_ratio +param.sp2 -1; % to get it from the start of embryo recording
    
elseif strcmp(place,'cortex')
    
    %-----------
    %-------------
    
    if general_param.cortex_analysis.AC_2parts ==0
        
        %-----------
        % strategy 1
        
        if ratio_smooth(1,1)>1.03
            limit_convex_ratio = ratio_smooth(1,1)+0.02;
        elseif ratio_smooth(1,1)<1.025 && ratio_smooth(1,1)>1.015
            limit_convex_ratio = ratio_smooth(1,1)+0.01;
        end
        
        for i = round(size(ratio_smooth,1)*image_studied_for_convex_ratio) : 1 : size(ratio_smooth,1)
            if (ratio_smooth(i) >= limit_convex_ratio)
                nb_large_convexity = nb_large_convexity +1;
                if nb_large_convexity == max_nb_large_convexity
                    start_cytokinesis_furrow = i;
                    break;
                end
            end
        end
        
        if start_cytokinesis_furrow == round(size(ratio_smooth,1)*image_studied_for_convex_ratio) + max_nb_large_convexity -1
            limit_convex_ratio_new = ratio_smooth(1,1)+0.015;
            nb_large_convexity = 0;
            for i = round(size(ratio_smooth,1)*image_studied_for_convex_ratio) : 1 : size(ratio_smooth,1)
                if (ratio_smooth(i) >= limit_convex_ratio_new)
                    nb_large_convexity = nb_large_convexity +1;
                    if nb_large_convexity == max_nb_large_convexity
                        start_cytokinesis_furrow = i;
                        break;
                    end
                end
            end
        end
        
        start_cytokinesis_furrow = start_cytokinesis_furrow + param.sp2 -1; % to get it from the start of embryo recording
        
        %------------
        %strategy2
        
        [datavalleys] = findinflections(ratio_smooth);
        
        for i = 1 : size(datavalleys,1)
            if ( datavalleys(i) > round(size(ratio_smooth,1)*image_studied_for_convex_ratio) ) && ...
                    ( ratio_smooth(datavalleys(i)) >= limit_convex_ratio ) && ...
                    ( datavalleys(i) < 2*round(size(ratio_smooth,1)*image_studied_for_convex_ratio) )
                nb_datavalleys=nb_datavalleys+1;
                ratio_datavalleys(nb_datavalleys) = ratio_smooth(datavalleys(i));
                image_datavalleys(nb_datavalleys)= datavalleys(i);
                image_datavalleys_raw(nb_datavalleys)= datavalleys(i);
            end
        end
        
        if exist('ratio_datavalleys','var')
            [C_min,I_min] = min(ratio_datavalleys);
            inflection_point_convexity_ratio = image_datavalleys(I_min);
            
            if C_min > limit_convex_ratio +0.01
                inflection_point_convexity_ratio = NaN;
                for j = 1 : size(datavalleys,1)
                    if ( ratio_smooth(datavalleys(j)) >= limit_convex_ratio -0.02 ) && ...
                            ( ratio_smooth(datavalleys(j)) <= limit_convex_ratio +0.01 ) && ...
                            ( datavalleys(j) < 2*round(size(ratio_smooth,1)*image_studied_for_convex_ratio) )
                        nb_datavalleys2=nb_datavalleys2+1;
                        image_datavalleys2(nb_datavalleys2)= datavalleys(j);
                    end
                end
            elseif C_min >= limit_convex_ratio-0.001 && C_min < limit_convex_ratio + 0.002
                inflection_point_convexity_ratio = NaN;
                for j = 1 : size(datavalleys,1)
                    if ( ratio_smooth(datavalleys(j)) >= limit_convex_ratio -0.02 ) && ...
                            ( ratio_smooth(datavalleys(j)) <= limit_convex_ratio +0.01 ) && ...
                            ( datavalleys(j) < 2*round(size(ratio_smooth,1)*image_studied_for_convex_ratio) )
                        nb_datavalleys2=nb_datavalleys2+1;
                        image_datavalleys2(nb_datavalleys2)= datavalleys(j);
                    end
                end
                
            end
            
            if exist('image_datavalleys2','var')
                [C_max,I_max] = max(image_datavalleys2);
                inflection_point_convexity_ratio = image_datavalleys2(I_max);
            end
            
        else
            for j = 1 : size(datavalleys,1)
                if ( ratio_smooth(datavalleys(j)) >= limit_convex_ratio -0.02 ) && ...
                        ( ratio_smooth(datavalleys(j)) <= limit_convex_ratio +0.01 ) && ...
                        ( datavalleys(j) < 2*round(size(ratio_smooth,1)*image_studied_for_convex_ratio) )
                    nb_datavalleys3=nb_datavalleys3+1;
                    image_datavalleys3(nb_datavalleys3)= datavalleys(j);
                end
            end
            
            if exist('image_datavalleys3','var')
                [C_max,I_max] = max(image_datavalleys3);
                inflection_point_convexity_ratio = image_datavalleys3(I_max);
            end
            
        end
        
        if isnan(inflection_point_convexity_ratio)
            [C,I] = min(ratio_smooth(round(size(ratio_smooth,1)*image_studied_for_convex_ratio):...
                2*round(size(ratio_smooth,1)*image_studied_for_convex_ratio)));
            inflection_point_convexity_ratio = round(size(ratio_smooth,1)*image_studied_for_convex_ratio)+I-1;
        end
        
        inflection_point_convexity_ratio = inflection_point_convexity_ratio +param.sp2 -1; % to get it from the start of embryo recording
        
        %------------
        %-----------
        
    elseif general_param.cortex_analysis.AC_2parts ==1
        
        if ratio_smooth(1,1)>1.035
            limit_convex_ratio = ratio_smooth(1,1)+0.02;
            
        else
            limit_convex_ratio = limit_convex_ratio + 0.02;
        end
        
        %-----------
        % strategy 1
        
        for i = round(size(ratio_smooth,1)*image_studied_for_convex_ratio) : 1 : size(ratio_smooth,1)
            if (ratio_smooth(i) >= limit_convex_ratio )
                nb_large_convexity = nb_large_convexity +1;
                if nb_large_convexity == max_nb_large_convexity
                    start_cytokinesis_furrow = i;
                    break;
                end
            end
        end
        
        start_cytokinesis_furrow = start_cytokinesis_furrow + param.sp2 -1;
        
        %------------
        %strategy2
        
        [datavalleys] = findinflections(ratio_smooth);
        
        for i = 1 : size(datavalleys,1)
            if ( datavalleys(i) > round(size(ratio_smooth,1)*image_studied_for_convex_ratio) ) && ...
                    ( ratio_smooth(datavalleys(i)) <= limit_convex_ratio ) && ...
                    ( datavalleys(i) < 2*round(size(ratio_smooth,1)*image_studied_for_convex_ratio) )
                nb_datavalleys=nb_datavalleys+1;
                ratio_datavalleys(nb_datavalleys) = ratio_smooth(datavalleys(i));
                image_datavalleys(nb_datavalleys)= datavalleys(i);
                image_datavalleys_raw(nb_datavalleys)= datavalleys(i);
            end
        end
        
        if exist('ratio_datavalleys','var')
            [C_max,I_max] = max(image_datavalleys);
            inflection_point_convexity_ratio = image_datavalleys(I_max);
            
        else
            for j = 1 : size(datavalleys,1)
                if ( ratio_smooth(datavalleys(j)) >= limit_convex_ratio -0.01 ) && ...
                        ( ratio_smooth(datavalleys(j)) <= limit_convex_ratio +0.01 ) && ...
                        ( datavalleys(j) < 2*round(size(ratio_smooth,1)*image_studied_for_convex_ratio) )
                    nb_datavalleys2=nb_datavalleys2+1;
                    image_datavalleys2(nb_datavalleys2)= datavalleys(j);
                end
            end
            
            if exist('image_datavalleys2','var')
                [C_max2,I_max2] = max(image_datavalleys2);
                inflection_point_convexity_ratio = image_datavalleys2(I_max2);
            end
            
        end
        
        if isnan(inflection_point_convexity_ratio)
            [C,I] = min(ratio_smooth(round(size(ratio_smooth,1)*image_studied_for_convex_ratio):...
                2*round(size(ratio_smooth,1)*image_studied_for_convex_ratio)));
            inflection_point_convexity_ratio = round(size(ratio_smooth,1)*image_studied_for_convex_ratio)+I-1;
        end
        
        inflection_point_convexity_ratio = inflection_point_convexity_ratio +param.sp2 -1;
        
    end
    
end


%--------------------

if param.landing_analysis == 1
    images_nb = transpose([param.sp2 : 1: length(ratio_brut)+param.sp2-1]); % every images between sp2 and sp3 (jump of 1)
else
    images_nb = transpose([param.sp2 : param.cortex_pass2.decimate : param.sp3]); %images between sp2 and sp3 with jump
end

figure

plot(images_nb(:),ratio_brut(:),'-b');
hold all
plot(images_nb(:),ratio_smooth(:),'-r');
xlabel ('images');
ylabel ('convexity ratio');
legend('raw ratio','smoothed ratio');
string1 = num2str(round(start_cytokinesis_furrow)); % in raw image between sp2 and sp3 with image 1 at start of recording
string5 = num2str( round(start_cytokinesis_furrow/param.sp6) ); % in sec from start of recording
string2 = ['image furrow = ' string1 ' = ' string5 'sec'];
text(50,50,string2,'Units','pixels')
string3 = num2str( round(inflection_point_convexity_ratio) );
string6 = num2str( round(inflection_point_convexity_ratio/param.sp6) );
string4 = ['image furrow (inflection point) = ' string3  ' = ' string6 'sec'];
text(50,100,string4,'Units','pixels')

figureName = strcat('plot_ratio_convexity-', short_name, param.extra,  '.fig');
saveas_perso(gcf,fullfile(pathMainDirectory,figureName));
figureName2 = strcat('plot_ratio_convexity-', short_name, param.extra,  '.tif');
saveas_perso(gcf,fullfile(pathDirectory_validation,figureName2));
saveas_perso(gcf,fullfile(pathMainDirectory,figureName2));
close (gcf)

%----------------
% select the correct image for furrow onset : to be optimized
if ( param.sp6 >= 5 && param.cortex_pass2.decimate == 1 )  || ( param.sp6 >=5 && param.cortex_pass2.decimate  ~= 1 && param.landing_analysis == 1 )
    if abs(start_cytokinesis_furrow - inflection_point_convexity_ratio) > 200
        image_detection = min(start_cytokinesis_furrow,inflection_point_convexity_ratio);
    else
        image_detection = max(start_cytokinesis_furrow,inflection_point_convexity_ratio);
    end
else
    if abs(start_cytokinesis_furrow - inflection_point_convexity_ratio) > 100
        %image_detection = min(start_cytokinesis_furrow,inflection_point_convexity_ratio);
        image_detection = start_cytokinesis_furrow; % suggested by Mélodie
    else
        image_detection = max(start_cytokinesis_furrow,inflection_point_convexity_ratio);
    end
end

furrow_detection_convexity.image_range = images_nb;
furrow_detection_convexity.ratio = ratio_brut;
% in frame nb within the whole set of images recorded
furrow_detection_convexity.image_detection = image_detection;

name = strcat('furrow_detection_convexity-', short_name,  param.extra, '.mat');
save(fullfile(pathMainDirectory,name), '-struct', 'furrow_detection_convexity');

%-----------------
% data saved to be used for xml_manual_timing_more

info_for_timing_furrow_ingression(:,1) = images_nb(:)./param.sp6; % time in sec with 0 at start of recording
info_for_timing_furrow_ingression(:,2) = ratio_smooth(:);
info_for_timing_furrow_ingression(:,3) = NaN(size(images_nb,1),1);
if exist('ratio_datavalleys','var')
    for i = 1 : size(image_datavalleys,2)
        info_for_timing_furrow_ingression(image_datavalleys_raw(i),3)= ratio_smooth(image_datavalleys_raw(i));
    end
end

name = strcat('furrow_detection_manual_timing-', short_name, param.extra, '.mat');
save(fullfile(pathMainDirectory,name), 'info_for_timing_furrow_ingression');

% plot similar to the one with xml_manual_timing
figure

plot(info_for_timing_furrow_ingression(:,1),info_for_timing_furrow_ingression(:,2),'b-');
hold all
plot(info_for_timing_furrow_ingression(:,1),info_for_timing_furrow_ingression(:,3),'c.');
grid on
grid minor
ylabel('area convexity');
xlabel('time (in sec)');

figureName3 = strcat('furrow_detection_manual_timing-', short_name, param.extra,  '.tif');
saveas_perso(gcf,fullfile(pathMainDirectory,figureName3));
close(gcf)

end
