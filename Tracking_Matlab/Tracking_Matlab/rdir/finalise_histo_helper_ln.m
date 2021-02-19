function [tmp_post_disp]=finalise_histo_helper_ln(post_disp, histo_half_width_freq_local, histo_steps_freq_local, fid, name)
    if nargin<5 || isempty(name)
        name = 'empty';
    end
    tmp_post_disp(:,1)=(histo_steps_freq_local*(-ceil(histo_half_width_freq_local/histo_steps_freq_local):ceil(histo_half_width_freq_local/histo_steps_freq_local)))';
    if size(tmp_post_disp,1)==size(post_disp,1)
        
        tmp_post_disp(:,2:3)=post_disp(:,2:3); % copy sum of values and error
        tmp_post_disp(:,4)=post_disp(:,1); % nb of samples per bin
        tmp_post_disp(tmp_post_disp(:,4)==0,:) = []; % remove lines where 0 as average
        tmp_post_disp(:,2)=tmp_post_disp(:,2)./tmp_post_disp(:,4); %divided by nb of samples to get average
        
        cond=tmp_post_disp(:,4)>0;
        % was done in finalize_histo_helper to get error, but wrong
%         tmp_post_disp(cond,3)=sqrt(...
%             (tmp_post_disp(cond,3)./(tmp_post_disp(cond,4) - 1) ... %sum of square over (n-1)
%         -(tmp_post_disp(cond,2).^2).*tmp_post_disp(cond,4)./(tmp_post_disp(cond,4)-1))./... % avg^2*n/(n-1)
%             tmp_post_disp(cond,4)  );
        % decipher the problem
%         tmp_post_disp(cond,5)=(tmp_post_disp(cond,3)./(tmp_post_disp(cond,4) - 1)  );  
%         tmp_post_disp(cond,6)= (tmp_post_disp(cond,2).^2).*tmp_post_disp(cond,4)./(tmp_post_disp(cond,4)-1);
%         tmp_post_disp(cond,7)= tmp_post_disp(cond,5) - tmp_post_disp(cond,6) ;    % negative values     
%         tmp_post_disp(cond,8)=sqrt( tmp_post_disp(cond,5) - tmp_post_disp(cond,6) );  % imaginar nb !!!
                
        % the correct results 
        tmp_post_disp(cond,3) = sqrt( tmp_post_disp(cond,3) ) ./ tmp_post_disp(cond,4) ;
        
      %  tmp_post_disp((tmp_post_disp(:,4)<=1),3)=NaN;
        if exist('fid','var') && ~isempty(fid)
            fprintf(fid,'%11.5f\t%10.10f\t%10.10f\t%10.10f\n',tmp_post_disp');
        end
    else
        warning_perso('Size mismatch in finalise histo helper (histo: %s)',name);
        % I already got this warning when step and half_width where different for normalized and non normalized histo.
    end
end
