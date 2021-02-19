function [ area_blastomere ] = to_get_area_blastomere( dbMaskedStack_rotated_anterior,regionArea,pathDirectory_validation,area_blastomere)

global pathMainDirectory
global param


if param.validation_embryoContour_alongTime == 0 || param.validation_polarity == 0 || param.validation_orientation_alongAP == 0
    
    %allocate the area matrix
    %num_images = size(regionArea.entireEmbryo.nbR1,1);
    num_images = size(dbMaskedStack_rotated_anterior,3); % for c briggsae
    area_blastomere = zeros(num_images,4);
    
    %for each picture of the stack
    for iImage =  1: num_images
        area_blastomere(iImage,1) = bwarea( dbMaskedStack_rotated_anterior(:,:,iImage) );
        area_blastomere(iImage,2) = regionArea.entireEmbryo.nbR1(iImage,1) - area_blastomere(iImage,1);
        %area_blastomere(iImage,2) = bwarea( dbMaskedStack_rotated_posterior(:,:,iImage) ) * ( (param.resol/1000)^2 ); % area in squared um
        %area_blastomere(iImage,3) = bwarea( dbMaskedStack_rotated_anterior_reduced(:,:,iImage) ) * ( (param.resol/1000)^2 ); % area in squared um
    end
    area_blastomere = area_blastomere .* ( (param.resol/1000)^2 );  % area in squared um
    clear dbMaskedStack_rotated_anterior
    
    if param.channel_total > 1
        area_blastomere(:,3) = transpose(1/param.sp6*[param.sp2 : param.channel_total  : param.sp3]);
    else
        if param.landing_analysis == 1
            area_blastomere(:,3)= transpose( [param.sp2 : param.decimate: param.sp3] ./ param.sp6 ); % in sec
        else
            area_blastomere(:,3)= transpose( [param.sp2 : param.cortex_pass2.decimate : param.sp3] ./ param.sp6 ); %images between sp2 and sp3 with jump
        end
    end
    area_blastomere(:,4) = area_blastomere(:,3) - param.furrow_detection_time;
    
    if isempty(param.extra) || ( ~isempty(param.extra) && strcmp(param.extra,'__no_tag__') )
        name = strcat('area_blastomere-', short_name, '.mat');
    else
        name = strcat('area_blastomere-', param.extra, short_name, '.mat');
    end
    save(fullfile(pathMainDirectory,name), 'area_blastomere');
   
elseif param.validation_embryoContour_alongTime == 1
    
    num_images = param.sp3 - param.sp2 +1; % ontriduce when problem with c briggsae
    time_vector(:) = area_blastomere(1:num_images,3);
    if sum(time_vector) == 0
        if param.landing_analysis == 1
            area_blastomere(1:num_images,3)= transpose( [param.sp2 : param.decimate : param.sp3] ./ param.sp6 ); % in sec
        else
            area_blastomere(1:num_images,3)= transpose( [param.sp2 : param.cortex_pass2.decimate : param.sp3] ./ param.sp6 ); %images between sp2 and sp3 with jump
        end
    end
    area_blastomere(:,4) = area_blastomere(:,3) - param.furrow_detection_time;
    
    if isempty(param.extra) || ( ~isempty(param.extra) && strcmp(param.extra,'__no_tag__') )
        name = strcat('area_blastomere-', short_name, '.mat');
    else
        name = strcat('area_blastomere-', param.extra, short_name, '.mat');
    end
    save(fullfile(pathMainDirectory,name), 'area_blastomere');
    
end


%% diplay evolution of area blastomere along time

index_0 = find(area_blastomere(:,4)>0,1);

figure('Visible','off')

plot(area_blastomere(index_0:end,4),area_blastomere(index_0:end,1),'b'); % in um2
hold all
plot(area_blastomere(index_0:end,4),area_blastomere(index_0:end,2),'r');
plot(area_blastomere(1:num_images,4),regionArea.entireEmbryo.nbR1(1:num_images,1).* ( (param.resol/1000)^2 ),'g'); % for c. briggsae
%plot(area_blastomere(:,4),regionArea.entireEmbryo.nbR1(:,1).* ( (param.resol/1000)^2 ),'g');
legend('anterior','posterior','whole');
xlabel('time (sec)');
ylabel('area (um^2)');
title('Evolution of the area of each blastomere along time');

namePlot = strcat('area_blastomere_Evolution-', short_name,  param.extra, '.fig');
saveas_perso(gcf,fullfile(pathMainDirectory,namePlot));
namePlot = strcat('area_blastomere_Evolution-', short_name,  param.extra, '.tif');
saveas_perso(gcf,fullfile(pathDirectory_validation,namePlot));
saveas_perso(gcf,fullfile(pathMainDirectory,namePlot));
close(gcf)


end

