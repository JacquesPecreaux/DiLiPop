function [c1,c2,recompute_c1_c2_mode]=Initialize_Image_params(recompute_c1_c2_mode,updating,...
    c1,c2,normalise,smoothing_for_region_values,imhist_nb,black_object,...
    Cxm,Cym,Imagee_,real_t,param_set)
   % this function update c1,c2,lambdaInside and lambdaOutside. It is
   % called for initialization (updating=0) and for updating to the next
   % frame (updating=1). c1 and c2 are in former case the parameter
   % provided by the user (-1 to have the values initialized automatically
   % or fixed values.
   %
   % modes are internally encoded between 1 and 999 for initialization and
   % 1000 and 999000 (not using traiparam.Ling 0) for updating , so =
   % updating?1000*recompute_c1_c2_mode:recompute_c1_c2_mode
   %
   % 1 used the double gaussian fit of image histogram, and could be used
   % for initialization. When updating, it doesn't take into acount any
   % history.
   % normalise specify when true (not 0) that constant of image in mmode 1/1001 is done on
   % normalized images then rescaled. It is a recommended option
   % smoothing_for_region_value allow a preliminary smoothing for image
   % constant detection. It is achieve by applying a squared shape averaging imfilter with size provided by this values
   %imhist_nb is the number of gray levels (2^# of bits)
   % black object flag indicate we are detecting a black object on a bright
   % background
   %
   % 2 try to correct from bleaching by measuring it with the ratio of
   % average of the image. if use as initialization, it uses method 1
   %
   % 3 take the ratio of algorithm 1 predicted c1 and c2 and predicted values in previous iteration
   % to measure bleaching and apply that factor to actual c1 and c2
   % provided by previous Tai and Yao run. In initialization provide only
   % the method 1
   %
   % method 4 and 5 are reserved and in fact used if user provide a function pointer for
   % recompute_c1_c2_mode. The funciton must return 2 arguments, c1 and c2
   % and can take up to 7 arguments, the current c1 and c2, the raw Imagee
   % (before preprocessing, the preprocessed one is available as global in
   % Imagee) the contour x and y at previous step and c1 and c2 guessed by
   % method 1.
   %
   % method 6 and 7 takes the average inside the contour on preprocessed image
   % and put it in c1, and average outside the contour and put it in c2. In
   % method 6, method 1 is used on first iteration when on method 7 the
   % initial contour is used as in any iteration
   %
   % method 8 maintain the initial c1 and c2 (even if Tai and Yao is selected and update it).
   % when intializing it uses the mehtod 1 
   %
   % methods with 1xx (and 1xx000 for update are for bandbased, using same
   % algo but bright is the contour only)
   
   % if not updating and no other method is specified initialization used
   % method 1
   %
   % method 0 cn be used to do nothing on update (but the Tai and Yao
   % update will still be active)
   %
   %
   % Note that when using Tai and Yao optimization of c1 and c2, it's only
   % about providing the starting c1 and c2
   %
   % N*100 and N*100000 (when updating) are reserved for band based active
   % contours.
   % 1 -> set the band average intensity to highest value, outside to lowest
   % and inside to the mean of the both previous one
   % 2 -> set the band average intensity to highest value, outside to lowest
   % and inside to the lowest (= to outside)
   %
   
 %%  
    absolute_lamba_X=1;
    global Imagee;
    global mean_for_bleaching_correct
    global mean_for_bleaching_correct_new
    global current_c1;
    global current_c2;
    global initial_c1;
    global initial_c2;
    global custom_c1_c2_update;
    global param;
    global Image_param;
    %global real_t;
    global Level_set_fct;
    global mask_init;
     global mask_BW_cropped;
     
    if isa(recompute_c1_c2_mode,'function_handle')
        custom_c1_c2_update=recompute_c1_c2_mode;
        if nargin(custom_c1_c2_update)<=5
            recompute_c1_c2_mode=4;
        else
            recompute_c1_c2_mode=5;
        end
    end
    c1_=c1;
    c2_=c2;
%% default behaviour if not implemented for lambda_in and out
if updating
    Band_based_key=round(recompute_c1_c2_mode/100000);
else
    Band_based_key=round(recompute_c1_c2_mode/100);
end
if Band_based_key>0
    param.(param_set).LinBAK=param.(param_set).Lin;
    param.(param_set).Lin=param.(param_set).Lcontour;
    Image_param.lambdaInsideBAKBAK=Image_param.lambdaInside;
    if isfield(Image_param,'Lcontour')
        Image_param.lambdaInside=Image_param.Lcontour;
    else
        Image_param.lambdaInside=nan;
    end
end
if ~isfield(Image_param,'lambdaInside')
    Image_param.lambdaInside=[];
end
if ~isfield(Image_param,'lambdaOutside')
    Image_param.lambdaOutside=[];
end
Image_param.lambdaInsideBAK=Image_param.lambdaInside;
Image_param.lambdaInside=NaN;
Image_param.lambdaOutsideBAK=Image_param.lambdaOutside;
Image_param.lambdaOutside=NaN; % to test whether they will be updated
%% for c1 and c2
    mmode=(1-updating)*mod(recompute_c1_c2_mode,100)+1000*updating*mod(recompute_c1_c2_mode,100);
    switch mmode
        case 0
            c1=0;
            c2=0;
            % used for algorithm not using c1 and c2 like Xu and Wang
        case {1,1000}
            [c1,c2]=get_param_perso(c1,c2,Imagee,normalise,absolute_lamba_X,smoothing_for_region_values,imhist_nb,black_object);
            % if c1 and c2 are already defined, there will not be
            % overwritten
        case {2,2000,14,14000}
         %   if mmode==2 || mmode == 2000
               Im=Imagee;
         %   else
         %       Im=Imagee_;
         %   end 
            if (param.(param_set).imtophat_image == 1) && (mmode==14 || mmode == 14000)
                ImageAdjust = imadjust(Im);
                mean_for_bleaching_correct_new=mean2(ImageAdjust);
            elseif (param.(param_set).maskFromInitialization_image == 1 )  && (mmode==14 || mmode == 14000)
                ImageAdjust = Im.*mask_init;
                ImageAdjust = imadjust(ImageAdjust);
                ImageAdjust(ImageAdjust == 0) = NaN;
                mean_for_bleaching_correct_new=nanmean2(ImageAdjust);
            elseif (~isempty(param.(param_set).mask_image)) && (mmode==14 || mmode == 14000)
                ImageAdjust = Im.*mask_BW_cropped;
                ImageAdjust = imadjust(ImageAdjust);
                ImageAdjust(ImageAdjust == 0) = NaN;
                mean_for_bleaching_correct_new=nanmean2(ImageAdjust);  
%             if (param.(param_set).imtophat_image == 1) || (param.(param_set).maskFromInitialization_image == 1 ) ...
%                      || ( ~isempty(param.(param_set).mask_image) )
%                  mean_for_bleaching_correct_new=mean2(Imagee);
            else
                mean_for_bleaching_correct_new=mean2(Imagee);
            end
            if ~isempty(mean_for_bleaching_correct)
                c1=c1*mean_for_bleaching_correct_new/mean_for_bleaching_correct;
                c2=c2*mean_for_bleaching_correct_new/mean_for_bleaching_correct;
            else
                [c1,c2]=get_param_perso(c1,c2,Imagee,normalise,absolute_lamba_X,smoothing_for_region_values,imhist_nb,black_object);
            end
            mean_for_bleaching_correct=mean_for_bleaching_correct_new;
        case {3,3000}
            [c1_,c2_]=get_param_perso(c1,c2,Imagee,normalise,absolute_lamba_X,smoothing_for_region_values,imhist_nb,black_object);
            if ~isempty(mean_for_bleaching_correct)
                c1=current_c1*c1_/mean_for_bleaching_correct_new(1);
                c2=current_c2*c2_/mean_for_bleaching_correct_new(2);
            else
                c1=c1_;
                c2=c2_;
            end
            mean_for_bleaching_correct_new=[c1_ c2_];
        case {4,5,4000,5000}
            if ~isempty(mean_for_bleaching_correct)
                if recompute_c1_c2_mode==4
                    [c1 c2]=custom_c1_c2_update_helper(custom_c1_c2_update,c1,c2,Imagee_,Cxm,Cym,current_c1,current_c2,real_t); % t is updated only by the virtual_time_loop fct
                else
                    [c1_,c2_]=get_param_perso(c1,c2,Imagee,normalise,absolute_lamba_X,...
                        smoothing_for_region_values,imhist_nb,black_object);
                    [c1 c2]=custom_c1_c2_update_helper(custom_c1_c2_update,current_c1,current_c2,Imagee_,Cxm,...
                        Cym,c1_,c2_,real_t); % t is updated only by the virtual_time_loop fct
               % we don't want to use initialization contour
                end
            else
                [c1,c2]=get_param_perso(c1,c2,Imagee,normalise,absolute_lamba_X,smoothing_for_region_values,imhist_nb,black_object);
                mean_for_bleaching_correct=1; % used as initilization marker
            end
        case {6,7,6000,7000}
            if recompute_c1_c2_mode==7 || ~isempty(mean_for_bleaching_correct)
                    BWM=poly2mask(Cym,Cxm,size(Imagee,1),size(Imagee,2));
                    c1=mean2(Imagee(BWM));
                    c2=mean2(Imagee(~BWM));
            else
                [c1,c2]=get_param_perso(c1,c2,Imagee,normalise,absolute_lamba_X,smoothing_for_region_values,imhist_nb,black_object);
                mean_for_bleaching_correct=1; % used as initilization marker
            end
        case {8,8000}
            if updating
                c1=initial_c1;
                c2=initial_c2;
            else
                [c1,c2]=get_param_perso(c1,c2,Imagee,normalise,absolute_lamba_X,smoothing_for_region_values,imhist_nb,black_object);
            end
        case {9,9000,11,11000,12,12000} % 11 differs by updating the lambda_X, 12 differs by using level_set_initialisation to estimate the fisrt c1 and c2 as well as lambda_X
            if param.(param_set).AC_method>=1000 || mmode==12
                if ~isempty(Level_set_fct)
                    continuous_heaviside=1/2*(1+2/pi*atan(Level_set_fct/param.(param_set).epsilon));
                    c1=sum(sum(Imagee.*continuous_heaviside))/sum(sum(continuous_heaviside));
                    c2=sum(sum(Imagee.*(1-continuous_heaviside)))/sum(sum((1-continuous_heaviside)));
                else
                    c1=NaN;
                    c2=NaN;
                end
            else
                BWM=poly2mask(Cym,Cxm,size(Imagee,1),size(Imagee,2));
                c1=mean2(Imagee(BWM));
                c2=mean2(Imagee(~BWM));
            end
        case {10,10000}
            c1=1;
            c2=mean2(Imagee_);
        case {13,13000}
            % from imageJ shanbhag algorithm
            Itmp = imfilter(Imagee,fspecial('average', 20));
            thresh_tmp = shanbhag_threshold(Itmp,imhist_nb);
            c1 = mean(Imagee(Itmp > thresh_tmp));
            c2 = mean(Imagee(Itmp <= thresh_tmp));            
        otherwise
            if ~updating
                [c1,c2]=get_param_perso(c1,c2,Imagee,normalise,absolute_lamba_X,smoothing_for_region_values,imhist_nb,black_object);
            end
    end
%% for lambdas
    switch mmode
        case {11,11000}
            % rely on 11 case in updating c1 and c2 above for precomputed
            % vars
            if param.(param_set).AC_method<1000 || mmode==12
                Image_param.lambdaOutside=param.(param_set).Lout*sum(sum(BWM))/numel(BWM);
                Image_param.lambdaInside=param.(param_set).Lin*sum(sum((~BWM)))/numel(BWM);
            else
                Image_param.lambdaOutside=param.(param_set).Lout*sum(sum(continuous_heaviside))/numel(Level_set_fct);
                Image_param.lambdaInside=param.(param_set).Lin*sum(sum((1-continuous_heaviside)))/numel(Level_set_fct);
            end
    end    
%% check NaN - make default cases
    if isnan(c1) || isnan(c2)
        warning_perso('NaN found in initialization of image params - switching to default method');
        [c1,c2,recompute_c1_c2_mode]=Initialize_Image_params(1,updating,...
            c1_,c2_,normalise,smoothing_for_region_values,imhist_nb,black_object,...
            Cxm,Cym,Imagee_,real_t);
%         ,...
%             param.Lin,param.Lout,Image_param.lambdaInside,Image_param.lambdaOutside); % note that we pass initial c1 and c2 through use of c1_and c2_
    end
    if isnan(Image_param.lambdaInside) || isnan(Image_param.lambdaOutside) % Lcontour is processed into Image_param.lambdaInside at that point
        if ~updating
            Image_param.lambdaInside=param.(param_set).Lin;
            Image_param.lambdaOutside=param.(param_set).Lout;
            Image_param.lambdaOutside0_norm=Image_param.lambdaOutside/param.(param_set).Lout;
        elseif ~isempty(param) && isfield(param.(param_set),'param.Lout_increase_per_frame') && ~isempty(param.(param_set).param.Lout_increase_per_frame)
                Image_param.lambdaOutside=Image_param.lambdaOutside*((param.(param_set).Lout+(real_t-2)*param.(param_set).param.Lout_increase_per_frame)/param.(param_set).Lout);
        elseif ~isempty(param) && isfield(param.(param_set),'param.Lout_exp_increase_exponent')...
            && isfield(param.(param_set),'param.Lout_exp_increase_norm')...
            && isfield(param.(param_set),'frame_0')...
            && ~isempty(param.(param_set).param.Lout_exp_increase_norm)...
            && ~isempty(param.(param_set).param.Lout_exp_increase_exponent)...
            && ~isempty(param.(param_set).frame_0)
                if real_t==2 || (real_t-2-param.(param_set).frame_0)==0
                    Image_param.lambdaOutside0_norm=Image_param.lambdaOutside/param.(param_set).Lout;
                end
                Image_param.lambdaOutside=Image_param.lambdaOutside0_norm*((param.(param_set).Lout-param.(param_set).param.Lout_exp_increase_norm)+...
                    param.(param_set).param.Lout_exp_increase_norm*(exp(param.(param_set).param.Lout_exp_increase_exponent*(real_t-2-param.(param_set).frame_0))));
                % beware Image_param.lambdaOutside was scaled respect from param.(param_set).Lout
        else
            Image_param.lambdaInside=Image_param.lambdaInsideBAK;
            Image_param.lambdaOutside=Image_param.lambdaOutsideBAK;
        end
    end
%% Band based AC adaptation
switch Band_based_key
    case 1
        % for both init and updating
        Image_param.c3=c1;
        c1=(c1+c2)/2;
    case 2
        Image_param.c3=c1;
        c1=c2;
end
if Band_based_key>0
    Image_param.Lcontour=Image_param.lambdaInside;
    Image_param.lambdaInside=Image_param.lambdaInsideBAKBAK;
    param.(param_set).Lin=param.(param_set).LinBAK;
%     if ~updating && (isempty(Image_param.lambdaInside) || isnan(Image_param.lambdaInside))
    Image_param.lambdaInside=param.(param_set).Lin;
%     end
end

 %% specific to updating   
    
    if ~updating
        initial_c1=c1;
        initial_c2=c2;
    end
    % for Tai and Yao
%     global current_c1;
%     global current_c2;
if ~updating
    current_c1=c1;
    current_c2=c2;   
end
end

