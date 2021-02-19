
%function rectangular_mask = get_rectangular_mask(mask_BW_saved,Imagee)
%        STATS = regionprops(mask_BW_saved);
function rectangular_mask = get_rectangular_mask(mask_BW,Imagee)
        STATS = regionprops(mask_BW);
%         rectangular_mask(1,1) = max(STATS.BoundingBox(1,1)-10,1);
%         if round(STATS.BoundingBox(1,3)+STATS.BoundingBox(1,1)+10) < size(Imagee,2)
%             rectangular_mask(1,3) = STATS.BoundingBox(1,3)+10;
%         else
%             rectangular_mask(1,3) = size(Imagee,2);
%         end
%         rectangular_mask(1,2) = max(STATS.BoundingBox(1,2)-10,1);
%         if round(STATS.BoundingBox(1,4)+STATS.BoundingBox(1,2)+10) < size(Imagee,1)
%             rectangular_mask(1,4) = STATS.BoundingBox(1,4)+10;
%         else
%             rectangular_mask(1,4) = size(Imagee,1);
%         end
        rectangular_mask(1,1) = max(STATS.BoundingBox(1,1),1);
        if round(STATS.BoundingBox(1,3)+STATS.BoundingBox(1,1)) < size(Imagee,2)
            rectangular_mask(1,3) = STATS.BoundingBox(1,3);
        else
            rectangular_mask(1,3) = size(Imagee,2);
        end
        rectangular_mask(1,2) = max(STATS.BoundingBox(1,2),1);
        if round(STATS.BoundingBox(1,4)+STATS.BoundingBox(1,2)) < size(Imagee,1)
            rectangular_mask(1,4) = STATS.BoundingBox(1,4);
        else
            rectangular_mask(1,4) = size(Imagee,1);
        end
end