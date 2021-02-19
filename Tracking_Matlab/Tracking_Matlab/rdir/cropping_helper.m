function [I, error_reading] = cropping_helper(I,II,tmp,cropping,mask_)
    % I is the image
    % cropping is the cropping method and mask_ the mask in use.
    global mask_BW;
    global running_mask_BW;
    global background;
    global rect_mask;
    global param;
    global running_mask_wo_rot;
    global mask_BW_AC;
    error_reading=0;
    
     if nargin<5 || isempty(mask_)
         mask_=param.mask;
     end
     if nargin<3 || isempty(II) || isempty(tmp)
         [II,tmp]=get_II_tmp(I);
     end


    if ~isempty(tmp)
        background=mean2(tmp);
    else
        background=mean2(II);
    end    
    
    switch(cropping)
        
        case {'mask'}
            if isempty(tmp)
                error_reading=1;
            else
                background=mean2(tmp);
                if ~isempty(mask_) && exist('mask_BW','var') && ~isempty(mask_BW)
                    % put background value outside the mask 6Very i;portqntm if not this mislead the tracking
                    I(~mask_BW)=background;
            %         I(~mask_BW)=0;
                    tmp=1:size(mask_BW,2);
                    tmp2=tmp(sum(mask_BW,1)>0);
                    first_col=min(tmp2);
                    last_col=max(tmp2);
                    tmp=1:size(mask_BW,1);
                    tmp2=tmp(sum(mask_BW,2)>0);
                    first_row=min(tmp2);
                    last_row=max(tmp2);
                    rect_mask=[first_col,first_row,last_col-first_col+1,last_row-first_row+1];
                    I=imcrop(I,rect_mask);
                    running_mask_BW=imcrop(mask_BW,rect_mask);
                    running_mask_wo_rot=running_mask_BW;
                else
                    mask_BW=[];
                    running_mask_BW=[];
                    running_mask_wo_rot=[];
                    rect_mask=[1 1 size(I,2) size(I,1)]; % required by tk1_tk2_process
                end
            end
    
        case {'rect_Roi'}
            if ~isempty(param.TrackRoi)
                mask_BW=zeros(size(I,1),size(I,2));
                mask_BW(round(1+param.TrackRoi(2)):round((1+param.TrackRoi(2)+param.TrackRoi(4))),round(1+param.TrackRoi(1)):round((1+param.TrackRoi(1)+param.TrackRoi(3))))=1;
                running_mask_BW=mask_BW;
                running_mask_wo_rot=mask_BW;
                I=imcrop(I,param.TrackRoi);
                rect_mask=[1 1 size(I,2) size(I,1)]; % required by tk1_tk2_process
            else
                mask_BW=[];
                running_mask_BW=[];
                running_mask_wo_rot=[];
                rect_mask=[1 1 size(I,2) size(I,1)]; % required by tk1_tk2_process
            end
                
        case {'AC_mask'}
            if isempty(tmp)
                error_reading=1;
            else
                background=mean2(tmp);
                if ~isempty(mask_) && exist('mask_BW','var') && ~isempty(mask_BW)
                    mask_BW_AC = mask_BW;  
                else
                    mask_BW_AC = [];
                end
            end
        %miss something about rect_mask? no because necesary for small
        %pictures that correspond to 'rect_Roi'
            
        case {'none'}
            mask_BW=[];
            running_mask_BW=[];
            running_mask_wo_rot=[];
            rect_mask=[1 1 size(I,2) size(I,1)]; % required by tk1_tk2_process
    end 
end