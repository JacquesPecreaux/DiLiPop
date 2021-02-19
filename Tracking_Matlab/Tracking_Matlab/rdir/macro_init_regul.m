% macro macro_init_regul
% Image_param.resolution=1e9/resol; so px / m (pixel per meter)
    mean_for_bleaching_correct=[];
    if param.(param_set).AC_method>=1000
        kappa=kap;%*resolution;
        % kappa_BAR is kappa x thickness and is already in good unit.
        % the resolution factor aim to correct for the unit of Phi which is
        % pixel
        % the energy term in kappa has no unit
    else
        kappa=kap*Image_param.resolution;
        % kappa_BAR is in J*[Contour fct unit] while sigma is in J/[level set fct unit]
        % indeed the term has the unit of the contour because the way to
        % write the unit of length differ. This unit of length is in pixel
        % and thus kappa should be scaled accordingly
    end
        
    sigma=sig/Image_param.resolution;
    lambda=lambda_;%*resolution;

    % WARNING  surface_regul initialozation is done in init_optim_method
    % since it is algorithm dependend ! WARNING