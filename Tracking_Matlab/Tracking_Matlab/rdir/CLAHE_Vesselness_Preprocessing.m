function L=CLAHE_Vesselness_Preprocessing(Iembryo,param_in)
    % parameters are either passed as second argument in the structure param
    % or are taken in the global param if the second parameter is not passed
    % or is empty
    % This function apply a wiener2 transform with a volume size
    % param_in.preprocess_wiener_size/param_in.resol
    % then a adapthisteq (CLAHE) and a FrangiFilter (Vesselness)
    % image is expected as double !
    
%     param_.preprocess_wiener_size=5000; % nm
%     param_.preprocess_clahe_neighborhood_size=40000; %nm
%     param_.preprocess_clahe_slope_limit=0.01;
%     param_.preprocess_vesselness_range=[1 8];
%     param_.preprocess_vesselness_step=1;
%     param_.resol=1000;
%     param_.max_level=256;
    
    global param;
    if nargin<2 || isempty(param_in)
        param_in=param;
    end
    if ~isfield(param_in,'preprocess_vesselness_invert') || isempty(param_in.preprocess_vesselness_invert) || ~param_in.preprocess_vesselness_invert
        I=(Iembryo-min(min(Iembryo)))/max(max((Iembryo-min(min(Iembryo)))));
    else
        I=1-(Iembryo-min(min(Iembryo)))/max(max((Iembryo-min(min(Iembryo)))));
    end
    J=wiener2(I,(param_in.preprocess_wiener_size/param_in.resol)*[1 1]); % kind of low pass filtering
    K=adapthisteq(J,'NumTiles',round(size(I)/(param_in.preprocess_clahe_neighborhood_size/param_in.resol)),'ClipLimit',param_in.preprocess_clahe_slope_limit,'NBins',param_in.max_level,'Range','full','Distribution','uniform'); %CLAHE
%%
    options.FrangiScaleRange=param_in.preprocess_vesselness_range;
    options.FrangiScaleRatio=param_in.preprocess_vesselness_step;
    options.BlackWhite=false;
    options.verbose=false;
    L=FrangiFilter2D(K,options);
end