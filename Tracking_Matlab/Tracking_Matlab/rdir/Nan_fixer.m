function [Cxm,Cym,reset_shape]=Nan_fixer(Cxm,Cym,resample_later)
    if ~exist('resample_later','var') || isempty(resample_later)
        resample_later=0;
    end
%%    
            idx=isnan(Cxm) | isnan(Cym);
            didx=diff(idx);
            One_idx=(2:length(idx));
            One_idx(didx~=1)=[];
            % this above vector contains all the first nan
            Minus_One_idx=(1:(length(idx)-1));
            Minus_One_idx(didx~=-1)=[];
            % this above vector contains all the last nan
            if isempty(One_idx) || isempty(Minus_One_idx)
                warning_perso('Setting flag for restarting with starting shape');
                reset_shape=1;
            else
                reset_shape=0;
                if (isnan(Cxm(1)) || isnan(Cym(1))) && (isnan(Cxm(length(Cxm))) || isnan(Cym(length(Cym))))
                    [Cxm,Cym]=loop_cutter_helper(One_idx(length(One_idx))-1,Minus_One_idx(1)+1,Cxm,Cym,length(Cxm));
                    One_idx(length(One_idx))=[];
                    Minus_One_idx(1)=[];
                elseif (isnan(Cxm(1)) || isnan(Cym(1))) && ~(isnan(Cxm(length(Cxm))) || isnan(Cym(length(Cym))))
                    [Cxm,Cym]=loop_cutter_helper(length(Cxm),Minus_One_idx(1)+1,Cxm,Cym,length(Cxm));
%                     One_idx(length(One_idx))=[];
                    Minus_One_idx(1)=[];
                elseif ~(isnan(Cxm(1)) || isnan(Cym(1))) && (isnan(Cxm(length(Cxm))) || isnan(Cym(length(Cym))))
                    [Cxm,Cym]=loop_cutter_helper(One_idx(length(One_idx))-1,1,Cxm,Cym,length(Cxm));
                    One_idx(length(One_idx))=[];
%                     Minus_One_idx(1)=[];
                end
                % One_idx and Minus_One_idx should have the same length
                for im_=1:length(One_idx)
                    [Cxm,Cym]=loop_cutter_helper(One_idx(im_)-1,Minus_One_idx(im_)+1,Cxm,Cym,length(Cxm));
                end
            end
%%
            if ~resample_later
                [Cxm,Cym]=equal_spacer([],length(Cxm),Cxm,Cym,[],param_set);
            end



end