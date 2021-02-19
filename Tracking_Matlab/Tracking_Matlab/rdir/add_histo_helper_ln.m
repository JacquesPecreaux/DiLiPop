    function [post_ampl,maxamp] = add_histo_helper_ln(amplitude,post_ampl,histo_steps_local,histo_half_width_local,tma)

        amplitude(any(~isfinite(amplitude(:,1:2)),2),:) = []; %clean up the NaN in column 1 or/and 2
        amp_idx=(-ceil(histo_half_width_local/histo_steps_local)):ceil(histo_half_width_local/histo_steps_local);
        amp_time=histo_steps_local*amp_idx;
        amplitude=check_series(amplitude); % removing duplicate times appearing rarely
        if size(amplitude,1)>=2
            [maxamp,~,~,sem]=resampler(amplitude,tma,amp_time,1,'uneven_running_average');
            post_ampl(amp_idx(~isnan(maxamp.data))+1+ceil(histo_half_width_local/histo_steps_local),:)=...
                post_ampl(amp_idx(~isnan(maxamp.data))+1+ceil(histo_half_width_local/histo_steps_local),:)+...
                [ ones(sum(~isnan(maxamp.data)),1) maxamp.data(~isnan(maxamp.data)) sem.data(~isnan(maxamp.data)).^2];
        elseif size(amplitude,1)==1
            warning_perso('Called add_histo_helper with a single point, adding to the closest bin');
        else
            warning_perso('Called add_histo_helper with empty data matrix - ignoring the call');
        end
                
    end
