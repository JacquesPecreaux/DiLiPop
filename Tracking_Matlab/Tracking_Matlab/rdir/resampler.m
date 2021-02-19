function [ts1x,Zero_point,count_per_bin,ts1x_sem,Zero_point_ts]=resampler(tk1mfmf,meta2ana_time,time_scale,far_interpolation_val,method,tk1mfmf_sem,ref_time_out_of_range_warning)
    global param;
    count_per_bin=NaN;
    ts1x_sem=[];
    if all(isnan(tk1mfmf(:,2)))
        ts1x=[];
        Zero_point=NaN;
        Zero_point_ts=NaN;
        return;
    end
    if ~exist('ref_time_out_of_range_warning','var') || isempty(ref_time_out_of_range_warning)
            ref_time_out_of_range_warning = 1;
    end
    if ~exist('far_interpolation_val','var') || isempty(far_interpolation_val)
        far_interpolation_val = nan; % value used for missing points: nan, 0. If far_interpolation_val is positive, then we will let the value obtained by interpolation
        % if the distance to nearest neightboor is below
        % far_interpolation_val /param.sp6
        % beware, if point are just shifted alltogether without
        % interpolation, this will result in a distance between 0 and 0.5
    end
    if ~exist('method','var') || isempty(method)
        method='linear';
    end
%%  
        if exist('meta2ana_time','var') && ~isempty(meta2ana_time) && isfinite(meta2ana_time)
            meta2ana_time_test=min(max(tk1mfmf(1,1)-param.fractional_time_matching_accuracy/param.sp6,meta2ana_time),...
                tk1mfmf(end,1)+param.fractional_time_matching_accuracy/param.sp6);
            if ref_time_out_of_range_warning && meta2ana_time~=meta2ana_time_test
                warning_perso('time_reference out of data range - keeping nevertheless the value assuming you know what you do');
            end
            time_shift=round(meta2ana_time*param.sp6)/param.sp6;
            tk1mfmf(:,1)=tk1mfmf(:,1)-time_shift;
        end

%%
    switch method
        case 'uneven_running_average'
            tk1mfmf(:,3)=interp1(time_scale,1:length(time_scale),tk1mfmf(:,1),'nearest','extrap');
            % we have now the index of the closest time_scale point for
            % each original point.
            time_scale_vals=0*time_scale;
            if nargout>=3
                count_per_bin=0*time_scale;
            end
            for ii=1:length(time_scale)
                time_scale_vals(ii)=mean(tk1mfmf(tk1mfmf(:,3)==ii,2)); % all non represented valued become NaN
                count_per_bin(ii)=sum(tk1mfmf(:,3)==ii);
            end
            count_per_bin=count_per_bin';
%             count_per_bin(count_per_bin==0)=[]; % these give NaN in time_scale_vals and are removed from ts1x
            ts1x=timeseries(reshape(time_scale_vals,[length(time_scale_vals) 1]),reshape(squeeze(time_scale),[length(time_scale) 1]));
            if (nargin>=6 && ~isempty(tk1mfmf_sem)) || nargout>=4
                   time_scale_sem = time_scale_vals;
            end
            if nargin>=6 && ~isempty(tk1mfmf_sem)
                for ii=1:length(time_scale)
                    time_scale_sem(ii)=sqrt(sum(tk1mfmf_sem(tk1mfmf(:,3)==ii).^2)/(count_per_bin(ii).^2));
                end
            elseif nargout>=4
                for ii=1:length(time_scale)
                    time_scale_sem(ii)=sqrt(sum((tk1mfmf(tk1mfmf(:,3)==ii,2) - time_scale_vals(ii)).^2)/((count_per_bin(ii)-1)*count_per_bin(ii)));
                end
            end
            if (nargin>=6 && ~isempty(tk1mfmf_sem)) || nargout>=4
                if ~isempty(time_scale_sem)
                    ts1x_sem=timeseries(reshape(time_scale_sem,[length(time_scale_sem) 1]),reshape(squeeze(time_scale),[length(time_scale) 1]));
                else
                    ts1x_sem = [];
                end
            end
        case 'downsampling_by_integer_factor_zeroth_order_hold'
            % assume input data equally sampled and time_scale even as well.
            % in this case, time_scale contains the reduction factor (number of point to average
            if numel(time_scale)==1 && round(time_scale)==time_scale 
                numel_trunc=floor(size(tk1mfmf,1)/time_scale);
                tk1mfmf=tk1mfmf(1:(time_scale*numel_trunc),:);
                tmpval=blkproc(tk1mfmf(:,2),[time_scale 1],@(x) mean2(x));
                tmptime=blkproc(tk1mfmf(:,1),[time_scale 1],@(x) mean2(x));
                ts1x=timeseries(tmpval,tmptime);
                %checked by plotting July 4th 2008
            else
                error('JACQ:RESAMP','downsampling_by_integer_factor_zeroth_order_hold called with a wrong time_scale');
            end
        otherwise
            ts1x= timeseries(tk1mfmf(:,2),tk1mfmf(:,1)); 
            if ~strcmp(method,'none')
                myFuncHandle = @(new_Time,Time,Data)interp1(Time,Data,new_Time,method,nan); % nan for extrapolation
                ts1x= setinterpmethod(ts1x,myFuncHandle);
            if ~exist('time_scale','var') || isempty(time_scale)
                    time_scale=(round(tk1mfmf(1,1)*param.sp6):round(tk1mfmf(size(tk1mfmf,1),1)*param.sp6))/param.sp6;
            end
            time_scale_mask=time_scale>=(min(ts1x.time)-param.fractional_time_matching_accuracy/param.sp6) & time_scale<=(max(ts1x.time)+param.fractional_time_matching_accuracy/param.sp6);
            if ts1x.Time(1)>time_scale(1) % To avoid the Nan in resample because of extrapolation
                time_scale(1) = time_scale(1) + param.fractional_time_matching_accuracy/param.sp6;
            end
            if ts1x.Time(end)<time_scale(end) % To avoid the Nan in resample because of extrapolation
                time_scale(end) = time_scale(end) - param.fractional_time_matching_accuracy/param.sp6;
            end
            ts1x_= resample(ts1x,time_scale(time_scale_mask)); %DEBUG Nan added here
            if any(~time_scale_mask)
                ts1x=addsample(ts1x_,'Data',NaN(length(time_scale(~time_scale_mask)),1),'Time',reshape(time_scale(~time_scale_mask),[1 length(time_scale(~time_scale_mask))]));
            else
                ts1x=ts1x_;
            end
         end
    end
    % in fact use only in the case where time_scale is not provided
    if nargout >= 2
        if ~isempty(param) && isfield(param,'sp6')
            [~,Zero_point]=min(abs(tk1mfmf(:,1)));
            [~,Zero_point_ts]=min(abs(ts1x.Time));
%             Zero_point=-round(tk1mfmf(1,1)*param.sp6)+1; % in matlab points are numbered from 1
        else
            Zero_point=nan;
            Zero_point_ts=nan;
        end
    end
    
%%  check that we are not interpolating too far away
    if isfinite(far_interpolation_val)
        if isnan(far_interpolation_val) || far_interpolation_val == 0 % if nan, we don't want far interpolation, if 0 we want ndft and use 0 for these, if other val then let the interp do the job
            fiv=far_interpolation_val;
        else
            fiv=nan;
        end
        switch method
            case {'none','nearest'}
                [~,idx_far_interp]=setxor(round(ts1x.Time*param.sp6),round(param.sp6*tk1mfmf(:,1)));
            otherwise
                D = pdist2(round(ts1x.Time*param.sp6),round(param.sp6*tk1mfmf(:,1)),'cityblock');
                D_nearest=min(D,[],2);
                idx_far_interp = find((D_nearest-far_interpolation_val)>0);
        end
        ts1x.data(idx_far_interp)=fiv;
    end
end
    
%% unit test
% test(:,1)=1:10;
% test(:,2)=10:-1:1;
% % without no_far_interpolation
% tmp2=resampler(test,0,amp_time)
% %with no_far_interpolation check
% tmp2=resampler(test,0,amp_time,1)


% figure_perso;
% test(:,1)=1:0.1:10;
% tmp2=resampler(test,0,1:0.5:10,0,'pchip')
% plot(test(:,1),test(:,2),'bd-'); hold on; plot(tmp2.time,tmp2.data,'go');
