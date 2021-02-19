%contour_plotter

                        if exist('Image_for_plot','var') && ~isempty(Image_for_plot) 
                            I=imadjust(Image_for_plot);
                        else
                            if strcmp(param_set,'tk1_tk2')
                            I=imadjust(Imagee_);
                            else
                                I = imadjust(Imagee);
                            end
                        end
                        imshow_perso(I); % plot by default by w/ axis ij
        %                 axis xy % very important for reprensenting in direct axes % flip (again w/ horiz axis
                        drawnow_perso;
                        hold_perso on
                        plot_ij(Cxm((shift+1):(Psize+shift+1),t),Cym((shift+1):(Psize+shift+1),t),'-g');
                        drawnow;
                        pathstr = getDatasetPath(param.stem_name, true);
                        namePlot = strcat('Single-contour_imageRef__', param.extra, '.fig');
                        saveas_perso(gcf,fullfile(pathstr,namePlot));
                        namePlot = strcat('Single-contour_imageRef__', param.extra, '.tif');
                        saveas_perso(gcf,fullfile(pathstr,namePlot));                        
