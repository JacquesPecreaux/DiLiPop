function [Imagee,Imagee_]=read_with_preprocess(image_stem,format_image,padding,first,number,...
    phase_contrast_preprocess_span,param_set,mask_image,is_init,adjust_image,filter_image,provided_image,...
    kalman_image,imtophat_image,clahe_image,maskFromInitialization_image,varargin)
%#function CLAHE_preprocess
%#function CLAHE_Vesselness_Preprocessing
%#function imtophat_preprocess
%#function wavelet_preprocessing
    global preprocess_kernel;
    global param;
    global ty;
    global mask_BW_cropped;
    global mask_BW
    global mask_init;
    global current_c2;
    global mask_of_halfFrame;
    global general_param;
    
    
    if nargin >= 17
        c1=varargin{1};
        if nargin >= 18
            c2=varargin{2};
    end
    end
        
    [Imagee,Imagee_,mask_BW_cropped_]=read_with_preprocess_core(format_image,padding,first,number,param_set,...
        mask_image,is_init,provided_image,kalman_image);
    if ~isempty(mask_BW_cropped_)
        mask_BW_cropped=mask_BW_cropped_;
    end
        
    %% %%%%%%% preprocess formerly here
    
    %% phase_contrast_preprocess with caching
    if (phase_contrast_preprocess_span)
       image_name2=sprintf(sprintf('%s.conv.tif',format_image),image_stem,first);
       if (size(dir(image_name2),1)~=0)
            Imagee_=Imagee(:,:,1);
            Imagee=im2double(imread(image_name2));
       else
            Imagee_=Imagee(:,:,1);
            Imagee=preprocess_phase_contrast(Imagee_,phase_contrast_preprocess_span);
            imwrite(Imagee,image_name2,'tif');
       end
    end
    
    %% custom preprocessing
    if isfield(param.(param_set),'preprocess_kernel') && ~isempty(param.(param_set).preprocess_kernel)
        preprocess_kernel=param.(param_set).preprocess_kernel;
    end   
           if ~isempty(preprocess_kernel)
        for ii_=1:size(Imagee,3) % support for multi-colors
                    Imagee(:,:,ii_)=preprocess_kernel(Imagee(:,:,ii_));
                end
            end
    %% color merging
            if isfield(param,'rgb_merging') && size(Imagee,3)>1
                Imagee(:,:,1)=param.(param_set).rgb_merging(1)*Imagee(:,:,1);
                for ii_=2:size(Imagee,3)
                    Imagee(:,:,1)=Imagee(:,:,1)+param.(param_set).rgb_merging(ii_)*Imagee(:,:,ii_);
                end
                Imagee(:,:,2:size(Imagee,3))=[];
                Imagee_=Imagee;
            else
                Imagee(:,:,1)=Imagee(:,:,1);
            end
    %% %%%%%%%  copied from init sequence in active_contour_real_time_loop
    if (adjust_image)
        Imagee=imadjust(Imagee);
    end
    if (filter_image)
        hgaus = fspecial('gaussian',[6 6],5);
        Imagee = imfilter(Imagee,hgaus);
    end

    %% copied from update sequence (into time loop) in active_contour_real_time_loop
    
    if general_param.cortex_analysis.AC_2parts ==0
        if  (~isempty(mask_image) && ~isempty(mask_BW) ) || ( (maskFromInitialization_image) && ~isempty(mask_init) )
            Imagee = Imagee.* iif( ~isempty(mask_image)  && ~isempty(mask_BW) ,mask_BW_cropped, mask_init) ;
        end
        [ Imagee] = Imagee_processor( Imagee,param_set,adjust_image,filter_image,imtophat_image,clahe_image );

        if  (~isempty(mask_image)  && ~isempty(mask_BW) ) || ( (maskFromInitialization_image) && ~isempty(mask_init) )
            Imagee = Imagee.* iif( ~isempty(mask_image)  && ~isempty(mask_BW) ,mask_BW_cropped, mask_init) ;
            if param.polar_body_presence == 1 && strcmp(param_set,'cortex_pass2') && ~isempty(mask_BW_cropped) 
                %Imagee = Imagee .* mask_BW_cropped .* mask_init;
                Imagee = Imagee .* mask_BW_cropped;
            end
            if is_init==1 % no c2 if initing
                 if ty == 0
                     if isempty( param.cortex_pass2.c2) && strcmp(param_set,'cortex_pass2')
                         Imagee(Imagee==0)=param.cortex_pass1.c2;
                     else
                         Imagee(Imagee==0)=param.(param_set).c2;
                     end
                 else
                    Imagee(Imagee==0)=current_c2;
                 end
            else
                 if ty == 0
                    Imagee(Imagee==0)=c2;
                 else
                    Imagee(Imagee==0)=current_c2;
                 end            

            end
        end
    elseif general_param.cortex_analysis.AC_2parts ==1
        if  (~isempty(mask_image) && ~isempty(mask_BW) ) || ( (maskFromInitialization_image) && ~isempty(mask_init) )
            Imagee = Imagee.* iif( ~isempty(mask_image)  && ~isempty(mask_BW) ,mask_BW_cropped, mask_init) ;
            Imagee = Imagee.* mask_of_halfFrame;
        end
        [ Imagee] = Imagee_processor( Imagee,param_set,adjust_image,filter_image,imtophat_image,clahe_image );

        if  (~isempty(mask_image)  && ~isempty(mask_BW) ) || ( (maskFromInitialization_image) && ~isempty(mask_init) )
            Imagee = Imagee.* iif( ~isempty(mask_image)  && ~isempty(mask_BW) ,mask_BW_cropped, mask_init) ;
            Imagee = Imagee.* mask_of_halfFrame;
            if is_init==1 % no c2 if initing
                 if ty == 0
                    Imagee(Imagee==0)=param.(param_set).c2;
                 else
                    Imagee(Imagee==0)=current_c2;
                 end
            else
                 if ty == 0
                    Imagee(Imagee==0)=c2;
                 else
                    Imagee(Imagee==0)=current_c2;
                 end            

            end
        end
    end
end
