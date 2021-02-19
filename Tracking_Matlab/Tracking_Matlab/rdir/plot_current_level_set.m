function plot_current_level_set(ite)
        % used by level set implementation
        global fig_LS;
        global Level_set_fct
        global Imagee;
        global param;
        global Image_param;
    if isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java
        return 
    end
       
        if ~exist('fig_LS','var')
            fig_LS=[];
        end
        fig_LS=clear_create_figure_perso(fig_LS,'Units','normalized','position',[0.1 0.1 0.8 0.8]);

        
        switch param.quick_plot
            
            case 1
                plot_level_set_current_case_1;
            case 2
            if isempty(param.clamp_quick_plot_scale)
                L=max(abs(-min(min(Level_set_fct))),max(max(Level_set_fct)));
            else
                L=param.clamp_quick_plot_scale;
            end
            tmp=(Level_set_fct+L)/(2*L);
                surf_perso(tmp(300:400,546:646));
                view(30,70);
            case 4
%             if isempty(param.clamp_quick_plot_scale)
%                 L=max(abs(-min(min(Level_set_fct))),max(max(Level_set_fct)));
%             else
%                 L=param.clamp_quick_plot_scale;
%             end
            imshow_perso(HeavisideThetaApprox(Level_set_fct,param.Bandwidth)/2+1/2);
%             tmp2=colormap('jet');
            h=colorbar;
            set(h,'YTick',[0 0.5 1]);
            set(h,'YTickLabel',{num2str(-1,'%g') '0' num2str(1,'%g')});
            title({['LSmin=' num2str(min(min(Level_set_fct)),'%g') ' LSmax=' num2str(max(max(Level_set_fct)),'%g')] ...
                ['ite=' num2str(ite,'%d') ' elpased=' num2str(etime(datevec(now),Image_param.start_datavec),'%10.2f')]});
            case 5
                plot_level_set_current_case_5;
            case 6
                plot_level_set_current_case_6;
            case 10
                subplot_perso(1,3,1);
                    plot_level_set_current_case_5;
                subplot_perso(1,3,2);
                    clamp_quick_plot_scale_bkp=param.clamp_quick_plot_scale;
                    param.clamp_quick_plot_scale=[];
                    plot_level_set_current_case_1;
                subplot_perso(1,3,3);
                    param.clamp_quick_plot_scale=clamp_quick_plot_scale_bkp;
                    plot_level_set_current_case_1;
            case 11
                subplot_perso(1,3,1);
                    plot_level_set_current_case_6;
                subplot_perso(1,3,2);
                    clamp_quick_plot_scale_bkp=param.clamp_quick_plot_scale;
                    param.clamp_quick_plot_scale=[];
                    plot_level_set_current_case_1;
                subplot_perso(1,3,3);
                    param.clamp_quick_plot_scale=clamp_quick_plot_scale_bkp;
                    plot_level_set_current_case_1;
           case 3
            logLevel_set_fct=zeros(size(Level_set_fct));
            logLevel_set_fct(Level_set_fct>0)=log(Level_set_fct(Level_set_fct>0))+100;
            logLevel_set_fct(Level_set_fct>0 & logLevel_set_fct<0)=0;
            logLevel_set_fct(Level_set_fct<0)=-log(-Level_set_fct(Level_set_fct<0))-100;
            logLevel_set_fct(Level_set_fct<0 & logLevel_set_fct>0)=0;
%             if isempty(param.clamp_quick_plot_scale)
%                 L=prctile(abs(logLevel_set_fct(:)),99);
%             else
                L=100;
%             end
            tmp=(logLevel_set_fct+L)/(2*L);
            imshow_perso(tmp);
            tmp2=colormap('jet');
            h=colorbar;
            set(h,'YTick',[0 0.5 1]);
            set(h,'YTickLabel',{num2str(-L,'%g') '0' num2str(L,'%g')});
            title({['(log plot) LSmin=' num2str(min(min(Level_set_fct)),'%g') ' LSmax=' num2str(max(max(Level_set_fct)),'%g')] ...
                ['ite=' num2str(ite,'%d') ' elpased=' num2str(etime(datevec(now),Image_param.start_datavec),'%10.2f')]});
%%            
            otherwise
%%
%                 end
%                 subplot_perso(1,2,1);
                imagesc(imadjust(Imagee),[0 1]);
                % doesn't work with imshow_perso to have different colormap
                axis off
                colormap gray
                hold_perso on
                ax1_=gca;
                CLim1      = get(ax1_,'CLim');
                
                ax2_ = axes('Parent',get(ax1_,'Parent'),'Position',get(ax1_,'Position'),'Visible','off');
                [C,h]=contour(Level_set_fct,'LineWidth',2.5);
                axis ij
                axis off
                linkaxes([ax1_ ax2_]);
                colormap jet
                CLim2      = get(ax2_,'CLim');
                
                cmap1=colormap('gray');
                cmap2=colormap('jet');
                cmap=[cmap1; cmap2];
                colormap(cmap);
                set(ax1_,'CLim',newclim(1,length(cmap1),CLim1(1),CLim1(2),length(cmap)));
                set(ax2_,'CLim',newclim(1+length(cmap1),length(cmap1)+length(cmap2),CLim2(1),CLim2(2),length(cmap)));
%                 col1=newclim(1+length(cmap1),length(cmap1)+length(cmap2),CLim2(1),CLim2(2),length(cmap));
%                 col2=(col1(1)+col1(2))/2;
%                 h=colorbar;
%                 set(h,'YTick',[ col1(1) col2 col1(2) ]);
%                 set(h,'YTickLabel',{num2str(min(min(Level_set_fct)),'%g') '0' num2str(max(max(Level_set_fct)),'%g')});
                title({['LSmin=' num2str(min(min(Level_set_fct)),'%g') ' LSmax=' num2str(max(max(Level_set_fct)),'%g')] ...
                ['ite=' num2str(ite,'%d') ' elpased=' num2str(etime(datevec(now),Image_param.start_datavec),'%10.2f')]});

%                 text_handle = clabel(C,h);
%                 set(text_handle,'BackgroundColor',[1 1 .6],'Edgecolor',[.7 .7 .7]);

%                 subplot_perso(1,2,2);
%                 surf_perso(Level_set_fct);
        end
                drawnow_perso;
                
end