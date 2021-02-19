function [Cxm,Cym]=bw2contour(BW,Cxm,Cym,t,param_set) %,no_equal_spacing)
    global param;
    global Image_param;
    if nargin<3
        Cxm=zeros(param.(param_set).Psize+2*Image_param.(param_set).shift,param.(param_set).Tsize);
        Cym=zeros(param.(param_set).Psize+2*Image_param.(param_set).shift,param.(param_set).Tsize);
    end
    if nargin<4
        t=1;
    end
    L = logical(BW);
    stats = regionprops(L, { 'PixelList', 'Area' });
    if ~isempty(stats)
        allArea = [stats.Area];% trick needed to get rid of issue with dirt or writing on image sides
        [~,idx]=max(allArea);
        allPx=stats(idx).PixelList; % all that in ij
        contourMin = [];
        contourMax = [];
        for i=min(allPx(:,1)):max(allPx(:,1))
            sub = allPx(allPx(:,1)==i,:);
            if ~isempty(sub)
                linePx = sub;
                if length(linePx)>=2
                    [dummy, minPos] = min(linePx(:,2));
                    [dummy, maxPos] = max(linePx(:,2));
                    contourMin = cat(1,contourMin, linePx(minPos,:));
                    contourMax = cat(1,contourMax, linePx(maxPos,:));
                else
                    contourMin = cat(1,contourMin, linePx(1,:));
                    contourMax = cat(1,contourMax, linePx(1,:));
                end
            end
        end
        contour = cat(1,contourMin, flipud(contourMax));
        
        [Cxm((Image_param.shift+1):(param.(param_set).Psize+Image_param.shift),t),Cym((Image_param.shift+1):(param.(param_set).Psize+Image_param.shift),t)]=...
            equal_spacer([],param.(param_set).Psize,contour(:,2),contour(:,1),[],param_set);
    else
        Cxm(:,t)=nan(size(Cxm,1),1);
        Cym(:,t)=nan(size(Cym,1),1);
    end
end