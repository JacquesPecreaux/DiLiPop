function [res,old_su,su,Cxm,Cym,no_final_energy,SD_from_base,SD_ite,processed_old]=...
    stop_condition_surface_SD(init,~,Cxm,Cym,~,~,~,~,~,old_su,su,~,~,no_final_energy,...
    SD_from_base,SD_ite,processed_old,Imagee,param_set)
    % I use SD_from_base to store initial image processed
  global param;
  global Level_set_fct;
  global Image_param;
    if param.(param_set).AC_method<1000
        error('Stop condition stop_condition_surface_SD apply only to level sets, not to parametric curve');
    end
%%
    res=[];
%%
    switch init
        case 1 % intialize
            % initialization of empty array in the call to the function
%%            
        case 2 %update
            old_su=su;
%%
        case 3 % test
            processed=Level_set_fct(:)-prctile(Level_set_fct(:),1);
            processed=processed/prctile(processed,99);
            processed(processed<0)=0;
            processed(processed>1)=1;
            if isempty(SD_from_base)
                SD_from_base=Imagee(:)-prctile(Imagee(:),1);
                SD_from_base=SD_from_base/prctile(SD_from_base,99);
                SD_from_base(SD_from_base<0)=0;
                SD_from_base(SD_from_base>1)=1;
            end
            if isempty(processed_old)
                processed_old=SD_from_base;
            end
            [SD_ite(length(SD_ite)+1)]=symmetric_divergence(processed_old,processed,[],[],100);
            SD_ite(length(SD_ite))=SD_ite(length(SD_ite))/Image_param.norm_SD;
            processed_old=processed;
%             save([con_name 'debugging_stop_condition.mat'],'SD_from_base','SD_ite','H_array');
            [su,has_converged,ite_still_to_be_done,old_su]=Postion_characteristic_length(SD_ite,param.(param_set).threshold_direct,param.(param_set).threshold_with_increase,old_su,param_set);
            switch has_converged
                case -3
                    disp('Size of step decreases consistently (level 3)');
                case -2
                    disp('Convergence still involve large steps (level 1)');
                case -1
                    disp('Size of step seems to decrease (level 2)');
                case 1
                    if symmetric_divergence(SD_from_base,processed,[],[],100)>param.(param_set).threshold_SD_from_original
                        disp('Stop condition reached, symmetric divergence exponential convergence (threshold_direct)');
                        res=10;
                    else
                        disp('Symmetric divergence exponential apparently has converged (threshold_direct) BUT to something far from original image');
                        has_converged=-4;
                    end
                case 2
                    disp('Stop condition reached, symmetric divergence exponential convergence (threshold_with_increase)');
                    res=11;
            end
            if has_converged<0
                disp(['Number of characteristic distances : ' sprintf('%g\n',su) 'iterations remaining estimated to : ' num2str(ite_still_to_be_done,'%d')]);
            end
            if has_converged<0
                res=has_converged;
            end
    end
end
