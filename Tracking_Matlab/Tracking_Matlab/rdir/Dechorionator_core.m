function Image_result = Dechorionator_core(Image_in, chorion_radius, resol, chorion_width, max_chorion_solidity, Chorion_tolerance_EccentricityRatio)
            % a way to get rid of the chorion membrane
            
            Image_result = Image_in;
%             tmp_fill=imfill(Image_result,'holes');
            L = logical(Image_in);
            stats = regionprops(L, { 'MajorAxisLength','MinorAxisLength','Area','Solidity','PixelIdxList'});
%             if 0
%                 imshow(bwlabel(L)/length(stats))
%                 stats = regionprops(L, { 'MajorAxisLength','MinorAxisLength','Area','Solidity','Centroid','PixelIdxList'});
%                 for i=1:length(stats)
%                     text(stats(i).Centroid(1),stats(i).Centroid(2),num2str(stats(i).Area,'%g'),'color','r')
%                 end
%             end
            % chorion is normally about 1um diameter, a few pixel broad so
            % larger than 500nm*2*pi*width
            % select on area
            allArea = [stats.Area]; % trick needed to get rid of issue with dirt or writing on image sides
%              if 0
%                 idx=(allArea>(chorion_radius*2*pi*chorion_width/(resol^2)));
%                 c_=colormap(jet(3*length(stats)));
%                 tmp=bwlabel(L)/(3*length(stats));
%                 idx_tmp=1;
%                 for i=1:length(stats)
%                     if idx(i)
%                         tmp(stats(i).PixelIdxList)=2/3+idx_tmp/sum(idx)/3;
%                         idx_tmp=idx_tmp+1;
%                     end
%                 end    
%                 imshow(tmp);
%                 colormap jet
%                 idx_tmp=1;
%                 for i=1:length(stats)
%                     if idx(i)
%                         text(stats(i).Centroid(1),stats(i).Centroid(2),num2str(stats(i).Solidity,'%g'),'color',c_(round((2+idx_tmp/sum(idx)/3)*length(stats)),:))
%                         idx_tmp=idx_tmp+1;
%                     end
%                 end
%             end
            allSolidity = [stats.Solidity]; % trick needed to get rid of issue with dirt or writing on image sides
%              if 0
%                 idx=(allArea>(chorion_radius*2*pi*chorion_width/(resol^2))) & allSolidity<max_chorion_solidity;
%                 c_=colormap(jet(3*length(stats)));
%                 tmp=bwlabel(L)/(3*length(stats));
%                 idx_tmp=1;
%                 for i=1:length(stats)
%                     if idx(i)
%                         tmp(stats(i).PixelIdxList)=2/3+idx_tmp/sum(idx)/3;
%                         idx_tmp=idx_tmp+1;
%                     end
%                 end    
%                 imshow(tmp);
%                 colormap jet
%                 idx_tmp=1;
%                 for i=1:length(stats)
%                     if idx(i)
%                         text(stats(i).Centroid(1),stats(i).Centroid(2),num2str(stats(i).Eccentricity,'%g'),'color',c_(round((2+idx_tmp/sum(idx)/3)*length(stats)),:))
%                         idx_tmp=idx_tmp+1;
%                     end
%                 end
%              end

            allMajorAxis = [ stats.MajorAxisLength ];
            allMinorAxis = [ stats.MinorAxisLength ];
            for i=1:length(stats)
                allEccentricityRatio(i) = [stats(i).MajorAxisLength/stats(i).MinorAxisLength]; % trick needed to get rid of issue with dirt or writing on image sides
            end
%              if 0
%                 c_=colormap(jet(3*length(stats)));
%                 tmp=bwlabel(L)/(3*length(stats));
%                 idx_tmp=1;
%                 for i=1:length(stats)
%                     if idx(i)
%                         tmp(stats(i).PixelIdxList)=2/3+idx_tmp/sum(idx)/3;
%                         idx_tmp=idx_tmp+1;
%                     end
%                 end    
%                 imshow(tmp);
%                 colormap jet
%                 idx_tmp=1;
%                 for i=1:length(stats)
%                     if idx(i)
%                         text(stats(i).Centroid(1),stats(i).Centroid(2),num2str(allEccentricityRatio(i),'%g'),'color',c_(round((2+idx_tmp/sum(idx)/3)*length(stats)),:))
%                         idx_tmp=idx_tmp+1;
%                     end
%                 end
%              end
            global debug_flag
            if ~isempty(debug_flag) && debug_flag
                for i=1:length(stats)
                    disp([ 'Shape #' num2str(i,'%d') ' area=' num2str(allArea(i),'%g') '  solidity=' num2str(allSolidity(i),'%g') '  eccentricity=' num2str(allEccentricityRatio(i)) ...
                       '   major axis=' num2str(allMajorAxis(i),'%g') '  minor axis=' num2str(allMinorAxis(i)) ]);
                end
                disp(['Chorion => area>' num2str((chorion_radius*2*pi*chorion_width/(resol^2)),'%g') '  solidity<' num2str(max_chorion_solidity,'%g') ...
                    '  abs(Eccentricity-1)<' num2str(Chorion_tolerance_EccentricityRatio,'%g') ...
                    '  MajorAxis / ((1+eccentricity^-2)/2) = radius/resol +- 10 %    MinorAxis / ((1+eccentricity^2)/2) = radius/resol +- 10 %' ]);
            end
            
            idx=(allArea>(chorion_radius*2*pi*chorion_width/(resol^2))) & allSolidity<max_chorion_solidity & abs(allEccentricityRatio-1)<Chorion_tolerance_EccentricityRatio & ...
                abs(1-allMajorAxis./((1+allEccentricityRatio.^-2)./2)./(chorion_radius./resol))<= 0.1 & ...
                abs(1-allMinorAxis./((1+allEccentricityRatio.^2)./2)./(chorion_radius./resol))<= 0.1;
            if sum(idx)==1
                disp('remove the chorion');
                [~,pos_]=max(idx);
                Image_result(stats(pos_).PixelIdxList)=0;
            else
                disp('no chorion found - continuing');
            end
end
            