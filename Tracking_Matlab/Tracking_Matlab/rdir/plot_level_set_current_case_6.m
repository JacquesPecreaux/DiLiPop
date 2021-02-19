% macro plot_level_set_current_case_6
            global param
    if ~(isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java)

           if isempty(param.clamp_quick_plot_scale)
                L=max(abs(-min(min(Level_set_fct))),max(max(Level_set_fct)));
            else
                L=param.clamp_quick_plot_scale;
            end
            imshow(DiracDeltaApprox(Level_set_fct,param.epsilon)/2);
            tmp2=colormap('jet');
%             h=colorbar;
%             set(h,'YTick',[0 0.5 1]);
%             set(h,'YTickLabel',{num2str(0,'%g') '0' num2str(1,'%g')});
            title({['LSmin=' num2str(min(min(Level_set_fct)),'%g') ' LSmax=' num2str(max(max(Level_set_fct)),'%g')] ...
                ['ite=' num2str(ite,'%d') ' elpased=' num2str(etime(datevec(now),Image_param.start_datavec),'%10.2f')]});
    end