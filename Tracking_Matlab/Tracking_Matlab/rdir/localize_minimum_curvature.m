
function [coordinates_minCurvature1,coordinates_minCurvature2,xCoordinate_furrow_2contours]=localize_minimum_curvature(imageStack_rotated)

global general_param;

index_2contours = [];
xCoordinate_furrow_2contours = NaN(size(imageStack_rotated,3),1);

%% transformation into polar coordinates
for ii_ = 1 : size(imageStack_rotated,3)
    BW = imageStack_rotated(:,:,ii_);
    [B] = bwboundaries(BW,'noholes');
    if length(B) == 2
        boundary1 = flipdim(B{1},2);
        boundary2 = flipdim(B{2},2);
        contour(:,1) = transpose([transpose(boundary1(:,1)) [transpose(boundary2(:,1))]]);
        contour(:,2) = transpose([transpose(boundary1(:,2)) [transpose(boundary2(:,2))]]);
        results.framewise{ii_}.raw_contour.Contour = contour;
        index_2contours = [ii_ [index_2contours] ];
        xCoordinate_furrow_2contours (ii_,1) = ( max((boundary1(:,1))) + min((boundary2(:,1))) )/2;
        clear boundary1
        clear boundary2
        clear contour
    elseif isempty(B)
        results.framewise{ii_}.raw_contour.Contour = nan;
    else
        boundary = flipdim(B{1},2);
        results.framewise{ii_}.raw_contour.Contour = boundary;
        clear boundary
    end
    
    if ~isempty(results.framewise{ii_}.raw_contour) && ~isempty(B)
        results.framewise{ii_}.center=...
            [mean(results.framewise{ii_}.raw_contour.Contour(:,1)) mean(results.framewise{ii_}.raw_contour.Contour(:,2))];
        results.framewise{ii_}.contour_polar=...
            zeros(size(results.framewise{ii_}.raw_contour.Contour));
        [results.framewise{ii_}.contour_polar(:,2),results.framewise{ii_}.contour_polar(:,1)]=...
            cart2pol(results.framewise{ii_}.raw_contour.Contour(:,1)-results.framewise{ii_}.center(1),...
            results.framewise{ii_}.raw_contour.Contour(:,2)-results.framewise{ii_}.center(2));
        
    else
        results.framewise{ii_}.center=nan;
        results.framewise{ii_}.contour_polar=nan;
    end
    
end


%%

for ii_=1:size(imageStack_rotated,3)
    Psize(ii_)=size(results.framewise{ii_}.raw_contour.Contour,1);
end
for ii_=1:size(imageStack_rotated,3)

     dx=nan(1,size(results.framewise{ii_}.raw_contour.Contour,1)+4);
     dxx=dx;
     dy=dx;
     dyy=dx;


    if ~isempty(results.framewise{ii_}.raw_contour.Contour) && ~any(any(~isfinite(results.framewise{ii_}.raw_contour.Contour)))

        % smooth the contour
     windowSize=12;
        Cxm=[ results.framewise{ii_}.raw_contour.Contour((size(results.framewise{ii_}.raw_contour.Contour,1)-windowSize):size(results.framewise{ii_}.raw_contour.Contour,1),1); ...
            results.framewise{ii_}.raw_contour.Contour(:,1); results.framewise{ii_}.raw_contour.Contour(1:windowSize,1)];
        Cym=[ results.framewise{ii_}.raw_contour.Contour((size(results.framewise{ii_}.raw_contour.Contour,1)-windowSize+1):size(results.framewise{ii_}.raw_contour.Contour,1),2); ...
            results.framewise{ii_}.raw_contour.Contour(:,2); results.framewise{ii_}.raw_contour.Contour(1:windowSize,2)];
        tmpx=filter(ones(1,windowSize)/windowSize,1,Cxm);
        tmpy=filter(ones(1,windowSize)/windowSize,1,Cym);
        Cxm_=tmpx((windowSize+ceil(1/2*windowSize)):(windowSize+ceil(1/2*windowSize)+size(results.framewise{ii_}.raw_contour.Contour,1)-1));
        Cym_=tmpy((windowSize+ceil(1/2*windowSize)):(windowSize+ceil(1/2*windowSize)+size(results.framewise{ii_}.raw_contour.Contour,1)-1));
        results.framewise{ii_}.smoothed_contour(:,1)=Cxm_;
        results.framewise{ii_}.smoothed_contour(:,2)=Cym_;

        % circular boundaries
         shift=2;
         Cxm=[Cxm_((length(Cxm_)-shift+1):length(Cxm_)); Cxm_; Cxm_(1:2)]; % smoothed version is included here
         Cym=[Cym_((length(Cym_)-shift+1):length(Cym_)); Cym_; Cym_(1:2)];

        t=1;

        % copied from virtual_time_loop_frameqork
        dxa=diff(Cxm(:,t)); dya=diff(Cym(:,t));
        dx((1+shift):(Psize(ii_)+shift))=(dxa((1+shift):(Psize(ii_)+shift))+dxa((1+shift-1):(Psize(ii_)+shift-1)))./2;
            dy((1+shift):(Psize(ii_)+shift))=(dya((1+shift):(Psize(ii_)+shift))+dya((1+shift-1):(Psize(ii_)+shift-1)))./2;
        dxxs=diff(dxa); dyys=diff(dya);
        dxx((shift):(Psize(ii_)+shift+1))=dxxs((shift-1):(Psize(ii_)+shift));
            dyy((shift):(Psize(ii_)+shift+1))=dyys((shift-1):(Psize(ii_)+shift));
        % end copied

    %     tmp=2.*(dx.^2+dy.^2).^(-5/2).*(dxx.*dy+(-1).*dx.*dyy); % -5/2 linear density of curvature
        tmp=(dx.^2+dy.^2).^(-3/2).*(-dxx.*dy+dx.*dyy); % -3/2 curvature
        results.framewise{ii_}.curvature=tmp((shift+1):(shift+Psize(ii_)));
        % smoothing curvature
      windowSize=12;
        tmp=[results.framewise{ii_}.curvature((length(results.framewise{ii_}.curvature)-windowSize+1):length(results.framewise{ii_}.curvature)) ...
            results.framewise{ii_}.curvature results.framewise{ii_}.curvature(1:windowSize)];
        tmp=filter(ones(1,windowSize)/windowSize,1,tmp);
        results.framewise{ii_}.curvature_smoothed=tmp(1+ceil((1+1/2)*windowSize):(ceil((1+1/2)*windowSize)+length(results.framewise{ii_}.curvature)));
    else
        results.framewise{ii_}.curvature_smoothed=nan(1,Psize(ii_));
        results.framewise{ii_}.curvature=nan(1,Psize(ii_));
    end
end


min_curvature1 = general_param.furrow_detection.limit_min_curvature*ones(size(imageStack_rotated,3),1);
min_curvature2 = general_param.furrow_detection.limit_min_curvature*ones(size(imageStack_rotated,3),1);

index_minCurvature1 = NaN(size(imageStack_rotated,3),1);
index_minCurvature2 = NaN(size(imageStack_rotated,3),1);

coordinates_minCurvature1 = NaN(size(imageStack_rotated,3),2);
coordinates_minCurvature2 = NaN(size(imageStack_rotated,3),2);

for ii=1:size(imageStack_rotated,3)
    
    for j = 1 : round(Psize(ii)/2)
        if results.framewise{ii}.curvature_smoothed(j) < min_curvature1(ii)
            min_curvature1(ii) = results.framewise{ii}.curvature_smoothed(j);
            index_minCurvature1(ii) = j;
        end
    end
    for j = round(Psize(ii)/2 +1) : Psize(ii)
        if results.framewise{ii}.curvature_smoothed(j) < min_curvature2(ii)
            min_curvature2(ii) = results.framewise{ii}.curvature_smoothed(j);
            index_minCurvature2(ii) = j;
        end
    end 
    
    if ~isnan(index_minCurvature1(ii))
        coordinates_minCurvature1(ii,1) = results.framewise{ii}.raw_contour.Contour(index_minCurvature1(ii),1);
        coordinates_minCurvature1(ii,2) = results.framewise{ii}.raw_contour.Contour(index_minCurvature1(ii),2);
    end
    if ~isnan(index_minCurvature2(ii))   
        coordinates_minCurvature2(ii,2) = results.framewise{ii}.raw_contour.Contour(index_minCurvature2(ii),2);
        coordinates_minCurvature2(ii,1) = results.framewise{ii}.raw_contour.Contour(index_minCurvature2(ii),1);
    end
    
        
end

if sum(isnan(index_minCurvature1))== size(imageStack_rotated,3) || sum(isnan(index_minCurvature2))== size(imageStack_rotated,3)
    
    general_param.furrow_detection.limit_min_curvature = -0.02;
    min_curvature1 = general_param.furrow_detection.limit_min_curvature*ones(size(imageStack_rotated,3),1);
    min_curvature2 = general_param.furrow_detection.limit_min_curvature*ones(size(imageStack_rotated,3),1);

    index_minCurvature1 = NaN(size(imageStack_rotated,3),1);
    index_minCurvature2 = NaN(size(imageStack_rotated,3),1);

    coordinates_minCurvature1 = NaN(size(imageStack_rotated,3),2);
    coordinates_minCurvature2 = NaN(size(imageStack_rotated,3),2);

    for ii=1:size(imageStack_rotated,3)

        for j = 1 : round(Psize(ii)/2)
            if results.framewise{ii}.curvature_smoothed(j) < min_curvature1(ii)
                min_curvature1(ii) = results.framewise{ii}.curvature_smoothed(j);
                index_minCurvature1(ii) = j;
            end
        end
        for j = round(Psize(ii)/2 +1) : Psize(ii)
            if results.framewise{ii}.curvature_smoothed(j) < min_curvature2(ii)
                min_curvature2(ii) = results.framewise{ii}.curvature_smoothed(j);
                index_minCurvature2(ii) = j;
            end
        end 

        if ~isnan(index_minCurvature1(ii))
            coordinates_minCurvature1(ii,1) = results.framewise{ii}.raw_contour.Contour(index_minCurvature1(ii),1);
            coordinates_minCurvature1(ii,2) = results.framewise{ii}.raw_contour.Contour(index_minCurvature1(ii),2);
        end
        if ~isnan(index_minCurvature2(ii))   
            coordinates_minCurvature2(ii,2) = results.framewise{ii}.raw_contour.Contour(index_minCurvature2(ii),2);
            coordinates_minCurvature2(ii,1) = results.framewise{ii}.raw_contour.Contour(index_minCurvature2(ii),1);
        end


    end    
    
end

end
