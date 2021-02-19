function [pos_,has_converged,ite_still_to_be_done,pos_array]=Postion_characteristic_length(SD_ite,threshold_direct,threshold_with_increase,pos_array,param_set)
global param;
pos_=NaN;
has_converged=-2;
ite_still_to_be_done=NaN;
start_pos=0; % param.max_iter_starting_shape
global debug__;
if isempty(debug__)
    debug__=false;
end
%%
x_1 = (1:numel(SD_ite))';
SD_ite = SD_ite(:);
% if debug__
% % Set up figure_perso to receive datasets and fits
%     f_ = clf_perso;
%     figure_perso(f_);
%     set(f_,'Units','Pixels','Position',[654 331 680 481]);
%     legh_ = []; legt_ = {};   % handles and text for legend
%     xlim_ = [Inf -Inf];       % limits of x axis
%     ax_ = axes;
%     set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
%     set(ax_,'Box','on');
%     axes(ax_); hold on;
% 
%     % --- Plot data originally in dataset "SD_ite"
%     h_ = line(x_1,SD_ite,'Parent',ax_,'Color',[0.333333 0 0.666667],...
%         'LineStyle','none', 'LineWidth',1,...
%         'Marker','.', 'MarkerSize',12);
%     xlim_(1) = min(xlim_(1),min(x_1));
%     xlim_(2) = max(xlim_(2),max(x_1));
%     legh_(end+1) = h_;
%     legt_{end+1} = 'SD_ite';
% 
%     % Nudge axis limits beyond data limits
%     if all(isfinite(xlim_))
%         xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
%         set(ax_,'XLim',xlim_)
%     else
%         set(ax_, 'XLim',[15.607903225806448, 39.577903225806438]);
%     end
% end


% --- Create fit "fit 1"

% Apply exclusion rule "lower-upper1"
if length(x_1)<(start_pos+3)
    warning_perso('Too few point to fit convergence exponential');
    pos_array(end+1)=NaN;
    return;
end
ex_ = false(length(x_1),1);
ex_([]) = 1;
ex_ = ex_ | (x_1 <= start_pos);
fo_ = fitoptions('method','NonlinearLeastSquares','Robust','On','Lower',[-Inf    0 -Inf],'Upper',[0 Inf Inf]);
% fo_lin = fitoptions('method','LinearLeastSquares','Robust','On','Lower',[0 -Inf],'Upper',[Inf Inf]);
ok_ = isfinite(x_1) & isfinite(SD_ite);
if ~all( ok_ )
    warning_perso( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [0.029959436182257049 0.20931758736479111 0.88950201160698239 ];
% st_lin = [0.2 0.5 ];
set(fo_,'Startpoint',st_);
% set(fo_lin,'Startpoint',st_lin);
set(fo_,'Exclude',ex_(ok_));
% set(fo_lin,'Exclude',ex_(ok_));
ft_ = fittype('a*exp(-b*x)+c',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a', 'b', 'c'});
% ft_lin=fittype('poly1');
% Fit this model using new data
% if sum(~ex_(ok_))<2  %% too many points excluded
%     warning_perso('Not enough data left to fit ''%s'' after applying exclusion rule ''%s''.','fit 1','lower-upper1')
%     return;
% else
%     [cf_lin,gof_lin] = fit(x_1(ok_),SD_ite(ok_),ft_lin,fo_lin);
% end
if sum(~ex_(ok_))>=3  %% too many points excluded
    [cf_,gof_] = fit(x_1(ok_),SD_ite(ok_),ft_,fo_);
else
    warning_perso('Not enough data left to fit ''%s'' after applying exclusion rule ''%s''.','fit 1','lower-upper1')
    pos_array(end+1)=NaN;
    return;
end

% Or use coefficients from the original fit:
% if debug__
%     % Plot this fit
%     h_ = plot(cf_,'fit',0.95);
%     h_lin = plot(cf_lin,'fit',0.95);
%     legend off;  % turn off legend from plot method call
%     set(h_(1),'Color',[1 0 0],...
%         'LineStyle','-', 'LineWidth',2,...
%         'Marker','none', 'MarkerSize',6);
% %     set(h_lin(1),'Color',[0 1 0],...
% %         'LineStyle','-', 'LineWidth',2,...
% %         'Marker','none', 'MarkerSize',6);
%     legh_(end+1) = h_(1);
%     legt_{end+1} = 'exp';
% %     legh_(end+1) = h_lin(1);
% %     legt_{end+1} = 'lin';
% 
%     % Done plotting data and fits.  Now finish up loose ends.
%     hold off;
%     leginfo_ = {'Orientation', 'vertical', 'Location', 'NorthEast'};
%     h_ = legend(ax_,legh_,legt_,leginfo_{:});  % create legend
%     set(h_,'Interpreter','none');
%     xlabel(ax_,'');               % remove x label
%     ylabel(ax_,'');               % remove y label
% end
%%
% if (gof_.sse/gof_.dfe) < (gof_lin.sse/gof_lin.dfe) % see NR p666-667 Chi^2/nu
    pos_=cf_.b*length(SD_ite);
    pos_array(end+1)=pos_;
    if (pos_>threshold_direct)
        has_converged=1;
    else
        if length(pos_array)>=2
            tmp=diff(pos_array)>0;
            for jj_=length(tmp):1
                if ~tmp
                    tmp(jj_:1)=false;
                    break;
                end
            end
            if sum(tmp)<4
                a=-1;
            else
                has_converged=-1;
                tmp=cat(2,false,tmp);
                [a,b,s_a,s_b,a_confidence_interv]=linear_fit_helper(cat(2,(1:length(pos_array(tmp)))',(pos_array(tmp))'),0.95);
            end
            if (a>0) && (s_a<(param.(param_set).linear_fit_quality_thresh*a))
                if (pos_>threshold_with_increase)
                    has_converged=2;
                else
                    ite_still_to_be_done=ceil((length(SD_ite)-start_pos)/pos_*threshold_with_increase+start_pos-length(SD_ite));
                    has_converged=-3;
                end
            else
                ite_still_to_be_done=ceil((length(SD_ite)-start_pos)/pos_*threshold_direct+start_pos-length(SD_ite));
            end
        else
            ite_still_to_be_done=ceil((length(SD_ite)-start_pos)/pos_*threshold_direct+start_pos-length(SD_ite));
        end
    end
        
% else
%     warning_perso('not an exponential convergence (still)');
%     return;
% end
%%
% if 0
%     %%
%     figure_perso;
%     pos_array=[];
%     for ii_=24:length(SD_ite)
%         [pos_,has_converged,ite_still_to_be_done,pos_array]=Postion_characteristic_length(SD_ite(21:ii_),10,6,pos_array);
%         if isnan(pos_)
%             pos_=0;
%         end
%         subplot(2,1,1);
%         switch has_converged
%             case -3
%                 plot(ii_,pos_,'bo');
%             case -2
%                 plot(ii_,pos_,'ro');
%             case -1
%                 plot(ii_,pos_,'mo');
%             case 1
%                 plot(ii_,pos_,'g.');
%             case 2
%                 plot(ii_,pos_,'go');
%         end
%         hold on;
%         if has_converged<0
%             subplot(2,1,2);
%             plot(ii_,ite_still_to_be_done,'kd');
%             hold on
%         end
%     end
%     %%
%     figure_perso;
%     param.linear_fit_quality_thresh=2;
% for ik_=1:7
%     switch ik_
%         case 1
%             load('C:\Documents and Settings\jacques\My Documents\Andy\070312_wt\_file=070312_s19.tif_frame=10_Lout=1_Lin=8_Lcontour=0.1_lambda=0.1_resamp=ENO2_resamp_every=1_diff=CENT4_sig=0.0004_kap=1.8e-011.Band-based_LS_0000000001.condebugging_stop_condition.mat')
%         case 2
%             load('C:\Documents and Settings\jacques\My Documents\Andy\070312_wt\_file=070312_s19.tif_frame=20_Lout=1_Lin=8_Lcontour=0.1_lambda=0.1_resamp=ENO2_resamp_every=1_diff=CENT4_sig=0.0004_kap=1.8e-011.Band-based_LS_0000000001.condebugging_stop_condition.mat')
%         case 3
%             load('C:\Documents and Settings\jacques\My Documents\Andy\070312_wt\_file=070312_s19.tif_frame=45_Lout=1_Lin=8_Lcontour=0.1_lambda=0.1_resamp=ENO2_resamp_every=1_diff=CENT4_sig=0.0004_kap=1.8e-011.Band-based_LS_0000000001.condebugging_stop_condition.mat')
%         case 4
%             load('C:\Documents and Settings\jacques\My Documents\Andy\070312_wt\_file=070312_s19.tif_frame=60_Lout=1_Lin=8_Lcontour=0.1_lambda=0.1_resamp=ENO2_resamp_every=1_diff=CENT4_sig=0.0004_kap=1.8e-011.Band-based_LS_0000000001.condebugging_stop_condition.mat')
%         case 5
%             load('C:\Documents and Settings\jacques\My Documents\Andy\070312_wt\_file=070312_s19.tif_frame=70_Lout=1_Lin=8_Lcontour=0.1_lambda=0.1_resamp=ENO2_resamp_every=1_diff=CENT4_sig=0.0004_kap=1.8e-011.Band-based_LS_0000000001.condebugging_stop_condition.mat')
%         case 6
%             load('C:\Documents and Settings\jacques\My Documents\Andy\070312_wt\_file=070312_s19.tif_frame=80_Lout=1_Lin=8_Lcontour=0.1_lambda=0.1_resamp=ENO2_resamp_every=1_diff=CENT4_sig=0.0004_kap=1.8e-011.Band-based_LS_0000000001.condebugging_stop_condition.mat')
%         case 7
%             load('C:\Documents and Settings\jacques\My Documents\Andy\070312_wt\_file=070312_s19.tif_frame=90_Lout=1_Lin=8_Lcontour=0.1_lambda=0.1_resamp=ENO2_resamp_every=1_diff=CENT4_sig=0.0004_kap=1.8e-011.Band-based_LS_0000000002.condebugging_stop_condition.mat')
%     end
%     pos_array=[];
%     for ii_=24:length(SD_ite)
%         [pos_,has_converged,ite_still_to_be_done,pos_array]=Postion_characteristic_length(SD_ite(21:ii_),8,4,pos_array);
%         if isnan(pos_)
%             pos_=0;
%         end
%         subplot(3,7,ik_);
%         switch has_converged
%             case -3
%                 plot(ii_,pos_,'bo');
%             case -2
%                 plot(ii_,pos_,'ro');
%             case -1
%                 plot(ii_,pos_,'mo');
%             case 1
%                 plot(ii_,pos_,'g.');
%             case 2
%                 plot(ii_,pos_,'go');
%         end
%         hold on;
%         ylim([0 8]);
%         if has_converged<0
%             subplot(3,7,7+ik_);
%             plot(ii_,ite_still_to_be_done,'kd');
% %             set(gca,'YScale','log');
%             ylim([0 30]);
%             hold on
%         end
%     end
%     subplot(3,7,14+ik_);
%     plot(SD_from_base(21:end),'b-');hold on;plot(SD_ite(21:end),'g-')
%     ylim([0 2]);
%     hold on
% end  
%     %%
% end