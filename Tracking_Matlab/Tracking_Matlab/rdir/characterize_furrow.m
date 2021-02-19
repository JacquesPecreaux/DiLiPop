function [furrow_onset_sec,furrow_position,furrow_characterization] = characterize_furrow...
    (name_,regionXlimit,regionXlength,maskedStack_rotated,pathDirectory_validation)

global general_param;
global param;
global pathMainDirectory;
global Imagee;
global con_name;
global mask_BW_AC;

p = mfilename('fullpath');
prog_version=Version_perso(p);
    
if nargin<=1
    
   % pathstr = getDatasetPath(param.stem_name, true);
    mainDirectory = 'contour detection';
    mkdir_perso(pathstr,mainDirectory);
    pathMainDirectory = strcat(pathstr , '/' , mainDirectory, '/');
    
    clear mainDirectory
    
    nameData = [sprintf('%s%s%s',pathMainDirectory,'regionXlimit-', short_name) '.mat'];
    nameData0 = [sprintf('%s%s%s',pathMainDirectory,'regionXlength-', short_name) '.mat'];
    if ~exist(nameData,'file') || ~exist(nameData0,'file')
        furrow_detection_time=0;
        furrow_characterization=1;
        furrow_position=[];
        return
    end
    regionXlimit = load(nameData);
    regionXlength = load(nameData0);
    
    
    if ~isempty(param.default_extra)
        if bitand(param.sp9,8192)
            tag = param.extra;
        else
            tag = param.default_extra;
        end
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
    clear vector_datum
    
    [ maskedStack_rotated ] = rotate_mask(maskedStack);
    clear maskedStack
    
end

%------------------------------
%create local folder "furrow_characterization"

mainDirectory = 'furrow_characterization';
pathMainDirectory = strcat(param.basepath , '/' , param.sp1 , '/' , mainDirectory, '/');

%------------------------------
% to get the x-coordinates after rotation of the position of
% the cytokinesis furrow along AP axis

[furrow_position] = get_cytokinesis_furrow(name_,maskedStack_rotated,regionXlimit,regionXlength,pathDirectory_validation);

if param.timing_key ~= 0
    furrow_detection_time = furrow_position.image_start_detection/param.sp6; % in sec.
    %       write_replace_entry(docNode,thisListItem,'furrow_detection_time',param.furrow_detection_time );
else
    furrow_detection_time = param.furrow_detection_time; % in sec
end

%----------------------------------------
% create a txt file with data about furrow characterization

name_ = basename_builder;
tag = param.extra;
id = [name_((end-3):(end))];
furrow_characterization_name=[sprintf('%s%s_%s_%s',pathMainDirectory,id,tag,short_name) '_furrowCharacterization.txt'];

fp1=fopen(furrow_characterization_name,'w');
fprintf(fp1,'Explicit_Active_Contour \n%s\n',prog_version);
fprintf(fp1,'\n');
fprintf(fp1,'AC_2parts \n%f\n',general_param.cortex_analysis.AC_2parts);
fprintf(fp1,'\n');
fprintf(fp1, 'place \n%s\n', general_param.furrow_detection.place);
fprintf(fp1,'\n');
if strcmp(general_param.furrow_detection.place,'cortex')
    if general_param.cortex_analysis.AC_2parts ==0
        fprintf(fp1, 'limit convex ratio: \t%f\n', general_param.furrow_detection.limit_convex_ratio_cortex);
    elseif general_param.cortex_analysis.AC_2parts ==1
        fprintf(fp1, 'limit convex ratio: \t%f\n', general_param.furrow_detection.limit_convex_ratio_cortex+0.02);
    end
    fprintf(fp1, 'max nb large convexity: \t%f\n',general_param.furrow_detection.max_nb_large_convexity_cortex);
    fprintf(fp1, 'image studied for convex ratio above total ratio: \t%f\n', general_param.furrow_detection.image_studied_for_convex_ratio_cortex);
elseif strcmp(general_param.furrow_detection.place,'midPlane')
    fprintf(fp1, 'limit convex ratio: \t%f\n', general_param.furrow_detection.limit_convex_ratio_midPlane);
    fprintf(fp1, 'max nb large convexity: \t%f\n',general_param.furrow_detection.max_nb_large_convexity_midPlane);
    fprintf(fp1, 'image studied for convex ratio above total ratio: \t%f\n', general_param.furrow_detection.image_studied_for_convex_ratio_midPlane);
end
if param.sp6 >=5
    fprintf(fp1, 'if NaN, min in nb last images equal to: \t%f\n',general_param.furrow_detection.nb_last_images_for_mean * 10);
else
    fprintf(fp1, 'if NaN, min in nb last images equal to: \t%f\n',general_param.furrow_detection.nb_last_images_for_mean);
end
fprintf(fp1,'\n');
if ~isnan(furrow_position.image_start_detection)
    if param.landing_analysis == 1
        fprintf(fp1,'Furrow detection image (reduced stack): \t%f%s%f\n',furrow_position.image_start_detection/param.cortex_pass2.decimate,...
            '/',size(maskedStack_rotated,3)/param.cortex_pass2.decimate);
    else
        fprintf(fp1,'Furrow detection image (reduced stack): \t%f%s%f\n',furrow_position.image_start_detection/param.cortex_pass2.decimate,...
            '/',size(maskedStack_rotated,3));
    end
    fprintf(fp1,'Furrow detection image (whole set): \t%f%s%f\n',furrow_position.image_start_detection);
    fprintf(fp1,'Furrow detection time in sec: \t%f\n',furrow_position.image_start_detection/param.sp6); % in sec
    fprintf(fp1,'Furrow detection position: \t%f\n',furrow_position.percent_length.mean);
    fprintf(fp1,'\n');
end
fclose_perso(fp1);

clear fp1
clear furrow_characterization_name

clear name_
clear tag
clear id
clear pathstr

furrow_characterization = 2;
furrow_onset_sec = round(furrow_position.image_start_detection/param.sp6);
if isnan(param.furrow_detection_time)
    param.furrow_position = NaN;
else
    param.furrow_position = furrow_position.percent_length.mean;
end

end