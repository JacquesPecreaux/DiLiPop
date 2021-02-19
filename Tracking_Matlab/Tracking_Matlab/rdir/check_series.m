function [tk1,tk2]=check_series(tk1,tk2)
   %%check if two line are related to the same time or if issue with time order

        tk1=sortrows(tk1,1);
        if (nargin==2)
            tk2=sortrows(tk2,1);
        end
        
        ixPx=(tk1(1:(size(tk1,1)-1),1)==tk1(2:size(tk1,1),1));
        if (~isempty(ixPx) && any(ixPx))
            warning_perso('I found two or more lines refering to the same time in tk1/posterior file! keeping the last one.');
%             ix2Px=[false; ixPx;];
%             tk1(ix2Px,:)=[];
              tk1(ixPx,:)=[];
        end
        if (nargin==2)
            ixPx=tk2(1:(size(tk2,1)-1),1)==tk2(2:size(tk2,1),1);
            if (~isempty(ixPx) && any(ixPx))
                warning_perso('I found two or more lines refering to the same time in tk2/anterior file! keeping the last one.');
    %             ix2Px=[false; ixPx;];
    %             tk2(ix2Px,:)=[];
                tk2(ixPx,:)=[];
            end
        else
            tk2=[];
        end
end