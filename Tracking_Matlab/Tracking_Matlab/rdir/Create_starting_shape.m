function [Cxm,Cym,Contour_init_mode]=Create_starting_shape(varargin)
global param;
global Imagee;
global init_contour_backup;
global Level_set_fct;
global Level_set_fct_backup;
global reinit_params;
global subcall;
global main_fct_params;
global Image_param;
global presentation_movie;
global last_detection_succeeded;
global mask_BW_AC;

Contour_init_mode=varargin{1};
Psize=varargin{2};
Tsize=varargin{3};
shift=varargin{4};
Cxm_init=varargin{5};
Cym_init=varargin{6};
frame=varargin{7};
if nargin<9
    error('Create_starting_shape take 9 args at min, 8th could be []');
end
% frame contains the frame on which we will run 
if ~isempty(varargin{8}) && varargin{8} % arg 9 is mandatory
    reinit_params = varargin(1:min(nargin,9));
    reinit_params{8} = [];
end
if nargin>=8 && ~isempty(varargin{8})
    initialize = varargin{8};
else
    initialize = 1; % this is the case where Nan_checker regenerate the initial levelset... it is indeed not an update but reinit_params_should not be saved
end
if nargin >= 9
    param_set=varargin{9};
end
if isempty(Contour_init_mode)
    Contour_init_mode=param.(param_set).Contour_init_mode;
end
if param.(param_set).reuse_initial_contour==2
    Cxm(:,1)=init_contour_backup(:,1);
    Cym(:,1)=init_contour_backup(:,2);
    return
end
%%
    % convertion LS to parametric (postprocessing)
    if isfield(param.(param_set),'LS2parametric_postprocessor') && ~isempty(param.(param_set).LS2parametric_postprocessor)
        switch param.(param_set).LS2parametric_postprocessor
            case 'dechorionator'
                param.(param_set).LS2p=@dechorionator;
            otherwise
                param.(param_set).LS2p=@(I) I;
        end
    else
        param.(param_set).LS2p=@(I) I;
    end
%%
Cxm=zeros(Psize+2*shift,Tsize);
Cym=zeros(Psize+2*shift,Tsize);
%Level_set_fct=[];
%%
switch Contour_init_mode
    case 0
        % nothing to do so far, but having it here prevent the warning on
        % unknown init mode
    case 1
        if (param.(param_set).AC_method>=1000 && (~exist('Cxm_init','var') || isempty(Cxm_init))) || ( param.(param_set).AC_method<1000  && (~exist('Cxm_init','var') || isempty(Cxm_init) || ~exist('Cym_init','var') || isempty(Cym_init)))
            Contour_init_mode=0;
            warning_perso('Contour_init_mode=2 but no initial contour provided, switching to default mode');
        else
            if param.(param_set).AC_method>=1000
                Level_set_fct=Cxm_init;
            else
                Cxm((shift+1):(Psize+shift),1)=Cxm_init; % Cxm_init is updated at each successfull iteration
                Cym((shift+1):(Psize+shift),1)=Cym_init;
            end    
        end
    case 2
        if isfield(param.(param_set),'object_size_expected') && ~isempty(param.(param_set).object_size_expected) && ...
                isfield(param.(param_set),'noise_cutting_size') && ~isempty(param.(param_set).noise_cutting_size)
            if param.(param_set).black_object_before_preprocessing
                im0=1-imadjust(Imagee);
            else
                im0=imadjust(Imagee);
            end
            im=imtophat(im0,strel('disk',param.(param_set).noise_cutting_size)); % get rid a bit of inhomogeneous illumination
            im=wiener2(im,[param.(param_set).object_size_expected,param.(param_set).object_size_expected]); % get rid of small particles
            im=imclose(im,strel('disk',round((param.(param_set).object_size_expected+param.(param_set).noise_cutting_size)/2))); % filling the inside of the yolk
            im=imopen(im,strel('disk',param.(param_set).object_size_expected)); % get rid of remaining small particles
            level = graythresh(im); % use Otsu method
            BW = im2bw(im,level);
            [Cxm,Cym]=bw2convex_contour(BW,Cxm,Cym,[],param_set);
%             L = logical(BW);
%             
%             stats = regionprops(L, { 'ConvexHull', 'Area' });
%             allArea = [stats.Area];
%             [dummy,idx]=max(allArea);
%             contour=stats(idx).ConvexHull; % all that in ij
% %             contour(:,1)=size(Imagee_,1)-contour(:,1)+1;
%             [Cxm((shift+1):(Psize+shift),1),Cym((shift+1):(Psize+shift),1)]=equal_spacer([],Psize,contour(:,2),contour(:,1));
        else
            Contour_init_mode=0;
            warning_perso('Invalid param.(param_set).object_size_expected or param.(param_set).noise_cutting_size, switching to default mode');
        end
    case 3
        % do nothing (case zero is the default fallback)
        g = mat2gray(Imagee);

        w = fspecial('average',10);
        g1 = imfilter(g, w);

        se = strel('disk', 50);
        g2 = imopen(g1, se);

        level = graythresh(g2);
        level = level + 0.20;
        g3 = im2bw(g2,level);

        se1 = strel('disk', 20);
        g4 = imdilate(g3, se1); 
        
        [Cxm,Cym]=bw2convex_contour(g4,Cxm,Cym,[],param_set);
        
    
    case 4
        if ~isempty(mask_BW_AC)  
            STATS = regionprops(mask_BW_AC);
            zeroCropImageY = max(STATS.BoundingBox(1,1)-10,1);
            zeroCropImageX  = max(STATS.BoundingBox(1,2)-10,1);
            [Cxm,Cym]=bw2convex_contour(mask_BW_AC,Cxm,Cym,[],param_set);
            Cxm(:,1)=Cxm(:,1)-zeroCropImageX;
            Cym(:,1)=Cym(:,1)-zeroCropImageY;
        else
            warning_perso('Asked for contour init mode 4 but provide no mask. Fall back to 0');
            Contour_init_mode = 0;
        end
        
    case 1000
        radius=floor(min(size(Imagee))/2);
        center=size(Imagee)/2;
        Xpos=((1:size(Imagee,1))-center(1))'*ones(1,size(Imagee,2));
        Ypos=ones(size(Imagee,1),1)*((1:size(Imagee,2))-center(2));
        Level_set_fct=10*sin(Xpos/radius*2*pi*5).*sin(Ypos/radius*2*pi*5);
        if param.(param_set).reinit_iterations>0
            Level_set_fct=Image_param.reinit_lsf(Level_set_fct,1, 1, 0.5, param.(param_set).LS_algo_diff_resamp, param.(param_set).reinit_iterations);%         figure_perso; surf(Level_set_fct);
        end
    case 1001
        radius=floor(min(size(Imagee))/2);
        center=size(Imagee)/2;
        Xpos=((1:size(Imagee,1))-center(1))'*ones(1,size(Imagee,2));
        Ypos=ones(size(Imagee,1),1)*((1:size(Imagee,2))-center(2));
        Level_set_fct=10*sin(Xpos/radius*2*pi/50).*sin(Ypos/radius*2*pi/50);
        if param.(param_set).reinit_iterations>0
            Level_set_fct=Image_param.reinit_lsf(Level_set_fct,1, 1, 0.5, param.(param_set).LS_algo_diff_resamp, param.(param_set).reinit_iterations);%         figure_perso; surf(Level_set_fct);
        end
    case 1002
        Level_set_fct=zeros(size(Imagee));
    case 1003
        radius=floor(min(size(Imagee))/2);
        center=size(Imagee)/2;
        Xpos=((1:size(Imagee,1))-center(1))'*ones(1,size(Imagee,2));
        Ypos=ones(size(Imagee,1),1)*((1:size(Imagee,2))-center(2));
        Level_set_fct=10*sin(Xpos/radius*2*pi/50).*sin(Ypos/radius*2*pi/50)-15;
        if param.(param_set).reinit_iterations>0
            Level_set_fct=Image_param.reinit_lsf(Level_set_fct,1, 1, 0.5, param.(param_set).LS_algo_diff_resamp, param.(param_set).reinit_iterations);%         figure_perso; surf(Level_set_fct);
        end
    case 1004
        radius=floor(min(size(Imagee))/2);
        center=size(Imagee)/2;
        Xpos=((1:size(Imagee,1))-center(1))'*ones(1,size(Imagee,2));
        Ypos=ones(size(Imagee,1),1)*((1:size(Imagee,2))-center(2));
        Level_set_fct=0.1*sin(Xpos/radius*2*pi/50).*sin(Ypos/radius*2*pi/50);
        if param.(param_set).reinit_iterations>0
            Level_set_fct=Image_param.reinit_lsf(Level_set_fct,1, 1, 0.5, param.(param_set).LS_algo_diff_resamp, param.(param_set).reinit_iterations);%         figure_perso; surf(Level_set_fct);
        end
    case 1010
        Level_set_fct=Imagee-graythresh(Imagee);
    case 2000
        % keep the previous level set value if detection was successful
        if ~last_detection_succeeded
            Contour_init_mode = param.(param_set).Contour_init_preinit_mode;
        end
    case 1100 % use Xu and Wang
        % default case, catched below, this one is here to prevent to run
        % otherwise
     otherwise % anyway the case 0 should be here
            Contour_init_mode=0;
            warning_perso('Initial contour mode not implemented - switching to default');
end
%% default cases
    switch Contour_init_mode
        case 0
            %it seems important that the primo contour cross the object!
            phase=3*pi/2;
            initial_size_1=(size(Imagee,2)-10); 
            initial_size_2=(size(Imagee,1)-10);
            initial_center_1=(size(Imagee,2));
            initial_center_2=(size(Imagee,1));
            Cxm((shift+1):(Psize+shift),1)=(initial_center_2+initial_size_2*sign(cos(2*pi/(Psize)*(1:Psize)+phase)).*(abs(cos(2*pi/(Psize)*(1:Psize)+phase))).^(1/4))/2;
            Cym((shift+1):(Psize+shift),1)=(initial_center_1+initial_size_1*sign(sin(2*pi/(Psize)*(1:Psize)+phase)).*(abs(sin(2*pi/(Psize)*(1:Psize)+phase))).^(1/4))/2;
         case 1100 % use Xu and Wang
            param_bkp=param;
            reinit_params_bkp=reinit_params;
            param.(param_set).AC_method=1000;
            if  initialize
                param.(param_set).Contour_init_mode=param.(param_set).Contour_init_preinit_mode;
            else
                param.(param_set).Contour_init_mode=param.(param_set).Contour_update_preinit_mode;
            end
            param.(param_set).max_iter=param.(param_set).max_iter_starting_shape;
            param.(param_set).stop_condition='None';
            main_fct_params{18}=param.(param_set).max_iter;
            subcall=1;
            main_fct_params{48}=param.(param_set).Contour_init_mode;
            main_fct_params{43}=0;
            main_fct_params{3}=param.(param_set).max_iter;
            main_fct_params{5}=param.(param_set).max_iter;
            main_fct_params{21}=1;
            main_fct_params{28}=frame;
            main_fct_params{29}=1;
            main_fct_params{19}=1;
            main_fct_params{31}=1;
            main_fct_params{32}=1;
            main_fct_params{36}=1;
            main_fct_params{37}=1;
            param.(param_set).Lcontour=1;
            param.(param_set).adaptative_new_step=2000000000000; % this large value is essential!
            pm = param.(param_set).presentation_movie;
            param.(param_set).presentation_movie = 0;
            presentation_movie = 0;
            if isfield(param.(param_set),'preprocess_kernel_starting_shape') && ~isempty(param.(param_set).preprocess_kernel_starting_shape)
                param.(param_set).preprocess_kernel=param.(param_set).preprocess_kernel_starting_shape;
            end
            active_contour_real_time_loop(main_fct_params{:});
            param.(param_set).presentation_movie = pm;
            presentation_movie = pm;
            param=param_bkp;
            reinit_params=reinit_params_bkp;
            subcall=0;
            init_optim_method(param_set); % in case of modifications
            if param.(param_set).AC_method>=1000
                Level_set_fct=Level_set_fct/max(max(abs(Level_set_fct)));
                resample_AC;
            end
    end

%% consistency check (NaN)
    if (param.(param_set).AC_method<1000 || isempty(Level_set_fct)) && (any(isnan(Cxm((1+shift):(Psize+shift),1))) || any(isnan(Cym((1+shift):(Psize+shift),1))))
            Contour_init_mode=0;
            warning_perso('NaN detected in initial contour, switching to default mode');
    end
    %% if non level set init use, then frame level set function
    if param.(param_set).AC_method>=1000 
        if Contour_init_mode<1000 && isempty(Level_set_fct)
            intialize_level_set_fct(Cxm,Cym,param_set);
        end
    else
        if Contour_init_mode>=1000
            tmp_LS=Level_set_fct/max(max(abs(Level_set_fct)));
            tmp_seg=im2bw(tmp_LS,graythresh(tmp_LS)); 
            tmp_seg=param.(param_set).LS2p(tmp_seg);
            tmp_fill=imfill(tmp_seg,'holes');
            [Cxm,Cym]=bw2convex_contour(tmp_fill,Cxm,Cym,[],param_set);
        end
    end
%% final steps in all modes        
    %problem of increasing inaccuracy of cos and sin with (1/4) power
    if param.(param_set).AC_method<1000
        Cxm(:,1)=round(10*Cxm(:,1))/10;
        Cym(:,1)=round(10*Cym(:,1))/10;
        if param.(param_set).reuse_initial_contour==1
    %         param.(param_set).reuse_initial_contour=2;
            init_contour_backup(:,1)=Cxm(:,1);
            init_contour_backup(:,2)=Cym(:,1);
        end
    else
        if param.(param_set).reuse_initial_contour==1
            Level_set_fct_backup=Level_set_fct;
            %param.(param_set).reuse_initial_contour=2;
        end
    end
end