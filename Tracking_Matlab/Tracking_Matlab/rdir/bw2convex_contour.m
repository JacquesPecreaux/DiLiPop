function [Cxm,Cym]=bw2convex_contour(BW,Cxm,Cym,t,param_set) %,no_equal_spacing)
    global param;
    global Image_param;
    if nargin<3
        Cxm=zeros(param.(param_set).Psize+2*Image_param.shift,param.(param_set).Tsize);
        Cym=zeros(param.(param_set).Psize+2*Image_param.shift,param.(param_set).Tsize);
    end
    if nargin<4 || isempty(t)
        t=1;
    end
    L = logical(BW);
    stats = regionprops(L, { 'ConvexHull', 'Area' });
    if ~isempty(stats)
        allArea = [stats.Area];% trick needed to get rid of issue with dirt or writing on image sides
        [~,idx]=max(allArea);
        contour=stats(idx).ConvexHull; % all that in ij
        %             contour(:,1)=size(Imagee_,1)-contour(:,1)+1;
    %     if ~exist('no_equal_spacing','var') || isempty(no_equal_spacing) || ~no_equal_spacing
            [Cxm((Image_param.shift+1):(param.(param_set).Psize+Image_param.shift),t),Cym((Image_param.shift+1):(param.(param_set).Psize+Image_param.shift),t)]=...
                equal_spacer([],param.(param_set).Psize,contour(:,2),contour(:,1),[],param_set);
    %     else
    %         Cxm((shift+1):(Psize+shift),1)=contour(:,2);
    %         Cym((shift+1):(Psize+shift),1)=contour(:,1);
    %     end
    else
        Cxm(:,t)=nan(size(Cxm,1),1);
        Cym(:,t)=nan(size(Cym,1),1);
    end
end