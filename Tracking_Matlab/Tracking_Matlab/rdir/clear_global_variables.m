% clear variables that are global

names_all_global = who('global');



for i = 1 : numel(names_all_global)
    if strcmp('Imagee',names_all_global{i})
        clear global Imagee
    elseif strcmp('mask_BW',names_all_global{i})
        clear global mask_BW
    elseif strcmp('mask_BW_AC',names_all_global{i})
        clear global mask_BW_AC
    elseif strcmp('mask_BW_cropped',names_all_global{i})
        clear global mask_BW_cropped
    elseif strcmp('mask_init',names_all_global{i})
        clear global mask_init
    elseif strcmp('rect_mask',names_all_global{i})
        clear global rect_mask
    elseif strcmp('Imagee_',names_all_global{i})
        clear global Imagee_
    elseif strcmp('current_c1',names_all_global{i})
        clear global current_c1
    elseif strcmp('current_c2',names_all_global{i})
        clear global current_c2
    elseif strcmp('running_mask_BW',names_all_global{i})
        clear global running_mask_BW
    elseif strcmp('firstContours_backup',names_all_global{i})
        clear global firstContours_backup
    elseif strcmp('fitsnom',names_all_global{i})
        clear global fitsnom
    elseif strcmp('imageStack_kalman',names_all_global{i})
        clear global imageStack_kalman
    elseif strcmp('pathMainDirectory',names_all_global{i})
        clear global pathMainDirectory
    elseif strcmp('siz',names_all_global{i})
        clear global siz
    elseif strcmp('running_mask_wo_rot',names_all_global{i})
        clear global running_mask_wo_rot
    elseif strcmp('mask_of_halfFrame',names_all_global{i})
        clear global mask_of_halfFrame
    elseif strcmp('xCoordinate_halfFrame',names_all_global{i})
        clear global xCoordinate_halfFrame
    end
end

