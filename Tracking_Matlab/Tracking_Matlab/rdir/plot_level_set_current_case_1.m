% macro plot_level_set_current_case_1
            
    if ~(isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java)


            if isempty(param.clamp_quick_plot_scale)
                L=prctile(abs(Level_set_fct(:)),95);
            else
                L=param.clamp_quick_plot_scale;
            end
            tmp=(Level_set_fct+L)/(2*L);
            imshow_perso(tmp);
            tmp2=colormap('jet');
            h=colorbar;
            set(h,'YTick',[0 0.5 1]);
            set(h,'YTickLabel',{num2str(-L,'%g') '0' num2str(L,'%g')});
            title({['LSmin=' num2str(min(min(Level_set_fct)),'%g') ' LSmax=' num2str(max(max(Level_set_fct)),'%g')] ...
                ['ite=' num2str(ite,'%d') ' elpased=' num2str(etime(datevec(now),Image_param.start_datavec),'%10.2f')]});
    end