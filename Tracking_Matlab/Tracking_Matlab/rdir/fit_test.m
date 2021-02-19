function cf_=fit_test(X,count,c1_c2_fixed,c1)
%FIT_TEST    Create plot of datasets and fits
%   FIT_TEST(X,COUNT)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1

 
% Data from dataset "count vs. X":
%    X = X:
%    Y = count:
%    Unweighted
%
% This function was automatically generated on 08-Nov-2005 09:45:54

% Set up figure_perso to receive datasets and fits
f_=figure_perso;
clf_perso(f_);
set(f_,'Units','Pixels','Position',[318 118.5 680 477]);
legh_ = []; legt_ = {};   % handles and text for legend
xlim_ = [Inf -Inf];       % limits of x axis
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
set(ax_,'Box','on');
axes(ax_); hold on;

 
% --- Plot data originally in dataset "count vs. X"
X = X(:);
count = count(:);
h_ = line(X,count,'Parent',ax_,'Color',[0.333333 0 0.666667],...
     'LineStyle','none', 'LineWidth',1,...
     'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(X));
xlim_(2) = max(xlim_(2),max(X));
legh_(end+1) = h_;
legt_{end+1} = 'count vs. X';

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
   xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
   set(ax_,'XLim',xlim_)
end

[A,I]=max(count);

% --- Create fit "fit 2"
fo_ = fitoptions('method','NonlinearLeastSquares','Lower',[0 0 0 ],'Upper',[Inf 1 Inf ]);

    
ok_ = ~(isnan(X) | isnan(count));
if c1_c2_fixed
    ft_ = fittype('gauss1','problem',{'b1'});
    st_ = [21496 c1 0.04705805700535 ];
else
    ft_ = fittype('gauss1');
    st_ = [21496 X(I) 0.04705805700535 ];
end
set(fo_,'Startpoint',st_);

% Fit this model using new data
try
    cf_ = fit(X(ok_),count(ok_),ft_ ,fo_);
catch e
    reporter(nan,e,mfilename);
    warning_perso('Fitting histogram failled, use mean and SD instead');
    b1=sum(X(ok_).*count(ok_))/sum(count(ok_));
    a1=max(count(ok_));
    c1=sqrt(sum(X(ok_).*X(ok_).*count(ok_))/sum(count(ok_))-b1^2);
    cf_=cfit(ft_,a1,b1,c1);
end
% Or use coefficients from the original fit:
if 0
   cv_ = {21488.64706906, X(I), 0.04452436019776};
   cf_ = cfit(ft_,cv_{:});
end

% Plot this fit
h_ = plot(cf_,'fit',0.95);
legend off;  % turn off legend from plot method call
set(h_(1),'Color',[1 0 0],...
     'LineStyle','-', 'LineWidth',2,...
     'Marker','none', 'MarkerSize',6);
legh_(end+1) = h_(1);
legt_{end+1} = 'fit 2';

% Done plotting data and fits.  Now finish up loose ends.
hold off;
h_ = legend(ax_,legh_,legt_,'Location','NorthEast');  
set(h_,'Interpreter','none');
xlabel(ax_,'');               % remove x label
ylabel(ax_,'');               % remove y label
