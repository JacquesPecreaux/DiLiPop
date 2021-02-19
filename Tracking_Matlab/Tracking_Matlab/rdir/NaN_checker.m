% macro - NaN_checker
force_resample=0;
global number_of_reset_on_nan
global param
global reinit_params;
%%
if param.(param_set).AC_method>=1000
    if any(any(~isfinite(Level_set_fct)))
        if number_of_reset_on_nan>0
            warning_perso('Divergence in levelset function, resetting');
            number_of_reset_on_nan=number_of_reset_on_nan-1;
            bkp=param.(param_set).Contour_update_preinit_mode;
            param.(param_set).Contour_update_preinit_mode=param.(param_set).Contour_init_preinit_mode;
            Create_starting_shape(reinit_params{:});
            param.(param_set).Contour_update_preinit_mode=bkp;
        else
            warning_perso('Divergence in levelset function, too many attempt of resetting, aborting this iteration');
            tt=param.(param_set).max_iter+1;
        end
        force_resample=1;
    end
else
    if any(isnan(Cxm((1+shift):(Psize+shift),t+1))) || any(isnan(Cym((1+shift):(Psize+shift),t+1)))
        force_resample=1;
        [Cxm((1+shift):(Psize+shift),t+1),Cym((1+shift):(Psize+shift),t+1),reset_shape]=...
            Nan_fixer(Cxm((1+shift):(Psize+shift),t+1),Cym((1+shift):(Psize+shift),t+1),1);
        if reset_shape
            old_su=[];
            continue_loop=1;
            t=2;
            tt=2; %tt is the "virtual time for gradient descent
            new_step_total=1;
            force_resample=0;
            tmp = reinit_params;
            tmp{1}=[];
            tmp{5}=[];
            tmp{6}=[];
            [X, Y]=Create_starting_shape(tmp{:});
            Cxm(:,t+1) = X(:,3);
            Cym(:,t+1) = Y(:,3);
        end
            % all nan should have been removed here
                        %%cyclic boundaries
            [Cxm(:,t+1),Cym(:,t+1)]=boundary_conditions(Cxm(:,t+1),Cym(:,t+1),Psize,shift,[],param_set);
    end
end

%% resample if needed
if force_resample
    resample_AC;
    force_resample=0; % do it now if there is nan
else
    force_resample=1; % schedule it after display
end