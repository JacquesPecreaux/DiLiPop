function [data_x_wenoY] = der_WENO_v_core(data_, dx,sign_,x_yes_or_y_no)
% sign_ should be 1 or -1 (or 0 for centerd in the future)


% if isempty(idx_iY) || any(size(idx_iY)~=any(size(data)- [6 0]))
%     idx_iY=(1:(size(data,1)-6))'*ones(1,size(data,2))+ones(size(data,1)-6,1)*((0:(size(data,2)-1))*(size(data,1)));
% end

% disp(['sign : ' num2str(sign_,'%d') '  x or y: ' num2str(x_yes_or_y_no,'%d')]);
persistent epsilon_helper epsilon_helper2;
% persistent idx_k;
persistent epsilon;
persistent data_x_wenoY_1 data_x_wenoY_2 data_x_wenoY_3;
persistent S1 S2 S3;
persistent alpha1 alpha2 alpha3 a_total;
persistent v1Y_ v2Y_ v3Y_ v4Y_ v5Y_;
persistent v1X_ v2X_ v3X_ v4X_ v5X_;
% persistent h1 h2 h3 he2 he1 he0;
persistent data;
% persistent data2 data3;
persistent result;
% persistent D1
% global v1Y v2Y v3Y v4Y v5Y


%
% Calculates the derivative (minus) using
% fifth order accurate WENO scheme
% takes 1-D data
% data: input data
% dx: grid resolution
% Note: before entering this function, data needs to be 
% extended by 3 at the beginning and end (values don't matter)
%
% Author: Baris Sumengen  sumengen@ece.ucsb.edu
% http://vision.ece.ucsb.edu/~sumengen/
%

%% vectorized b Jacques Pecreaux on June 29th 2009


% extrapolate the beginning and end points of data

%%
% extrapolate the beginning and end points of data
% tic %Elapsed time is 0.000096 seconds.
data_(3,:) = 2*data_(4,:)-data_(5,:);
data_(2,:) = 2*data_(3,:)-data_(4,:);
data_(1,:) = 2*data_(2,:)-data_(3,:);
data_(end-2,:) = 2*data_(end-3,:)-data_(end-4,:);
data_(end-1,:) = 2*data_(end-2,:)-data_(end-3,:);
data_(end,:) = 2*data_(end-1,:)-data_(end-2,:);
% toc

% tic %Elapsed time is 0.042523 seconds.
% h3=2*data(4,:)-data(5,:);
% h2=2*h3-data(4,:);
% h1=2*h2-data(3,:);
% he2=2*data(end-3,:)-data(end-4,:);
% he1=2*he2-data(end-3,:);
% he0=2*he1-data(end-2,:);
% data_=cat(1,h1,h2,h3,data(4:(end-3),:),he2,he1,he0);
% toc
% data=data_;
% checked oct 8th with any(any(~(D1==data | (isnan(D1) & isnan(data)))))
% if 0
% tic % 0.06
% D1=nan(size(data)); % to ensure the same shape as data and F
% D1_=diff(data,1,1);
% D1(1:(size(data,1)-1),:)=D1_/dx;
% toc
% data=D1;
% end
% speed improved from above
% tic % 0.03

%if sign_>0
data=cat(1,diff(data_,1,1)/dx,nan(1,size(data_,2)));
%  tic
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if 0
% 
% data(3) = 2*data(4)-data(5);
% data(2) = 2*data(3)-data(4);
% data(1) = 2*data(2)-data(3);
% data(end-2) = 2*data(end-3)-data(end-4);
% data(end-1) = 2*data(end-2)-data(end-3);
% data(end) = 2*data(end-1)-data(end-2);
% 
% D1 = (data(2:end)-data(1:end-1))/dx;
% 
% 
% end
%
if sign_<0
%     idx_k=idx_iY-1;
    idx_help=6;
elseif sign_>0
%     idx_k=idx_iY;
    idx_help=-1;
end
% if 0
% % tic
% % this is a much faster solution than reporting indexes everywhere --
% % indexing slow down computations
% % ONLY FOR MINUS WENO
% v1Y=data(idx_k+1);
% v2Y=data(idx_k+2);
% v3Y=data(idx_k+3);
% v4Y=data(idx_k+4);
% v5Y=data(idx_k+5);
% % toc
% end
% purpose is to have separate persistent for x and y and avoid reallocating
% when changing dimension
% faster than above implementation (checked also for same result)
if x_yes_or_y_no
%     tic % no significant difference 0.19
%     v1X_=data; v1X_(:,(end-(idx_help+sign_)):end)=[]; v1X_(:,1:(5-(idx_help+sign_)))=[];
%     v2X_=data; v2X_(:,(end-(idx_help+2*sign_)):end)=[]; v2X_(:,1:(5-(idx_help+2*sign_)))=[];
%     v3X_=data; v3X_(:,(end-(idx_help+3*sign_)):end)=[]; v3X_(:,1:(5-(idx_help+3*sign_)))=[];
%     v4X_=data; v4X_(:,(end-(idx_help+4*sign_)):end)=[]; v4X_(:,1:(5-(idx_help+4*sign_)))=[];
%     v5X_=data; v5X_(:,(end-(idx_help+5*sign_)):end)=[]; v5X_(:,1:(5-(idx_help+5*sign_)))=[];
%     toc % Elapsed time is 0.186540 seconds.

%      tic % 0.19
%     v1X_=data; v1X_((end-(idx_help+sign_)):end,:)=[]; v1X_(1:(5-(idx_help+sign_)),:)=[];
%     v2X_=data; v2X_((end-(idx_help+2*sign_)):end,:)=[]; v2X_(1:(5-(idx_help+2*sign_)),:)=[];
%     v3X_=data; v3X_((end-(idx_help+3*sign_)):end,:)=[]; v3X_(1:(5-(idx_help+3*sign_)),:)=[];
%     v4X_=data; v4X_((end-(idx_help+4*sign_)):end,:)=[]; v4X_(1:(5-(idx_help+4*sign_)),:)=[];
%     v5X_=data; v5X_((end-(idx_help+5*sign_)):end,:)=[]; v5X_(1:(5-(idx_help+5*sign_)),:)=[];
%       toc %Elapsed time is 0.174814 seconds.
% tic % 0.14
    v1X_=data((5-(idx_help+sign_)+1):(end-(idx_help+sign_)-1),:);
    v2X_=data((5-(idx_help+2*sign_)+1):(end-(idx_help+2*sign_)-1),:);
    v3X_=data((5-(idx_help+3*sign_)+1):(end-(idx_help+3*sign_)-1),:);
    v4X_=data((5-(idx_help+4*sign_)+1):(end-(idx_help+4*sign_)-1),:);
    v5X_=data((5-(idx_help+5*sign_)+1):(end-(idx_help+5*sign_)-1),:);
% toc 
    
    



    
    v1Y=v1X_; v2Y=v2X_; v3Y=v3X_; v4Y=v4X_; v5Y=v5X_; % normally matlab will act by pointer...
else
% tic
%     v1Y_=data; v1Y_((end-(idx_help+sign_)):end,:)=[]; v1Y_(1:(5-(idx_help+sign_)),:)=[];
%     v2Y_=data; v2Y_((end-(idx_help+2*sign_)):end,:)=[]; v2Y_(1:(5-(idx_help+2*sign_)),:)=[];
%     v3Y_=data; v3Y_((end-(idx_help+3*sign_)):end,:)=[]; v3Y_(1:(5-(idx_help+3*sign_)),:)=[];
%     v4Y_=data; v4Y_((end-(idx_help+4*sign_)):end,:)=[]; v4Y_(1:(5-(idx_help+4*sign_)),:)=[];
%     v5Y_=data; v5Y_((end-(idx_help+5*sign_)):end,:)=[]; v5Y_(1:(5-(idx_help+5*sign_)),:)=[];
% toc %Elapsed time is 0.176193 seconds.
% tic
    v1Y_=data((5-(idx_help+sign_)+1):(end-(idx_help+sign_)-1),:);
    v2Y_=data((5-(idx_help+2*sign_)+1):(end-(idx_help+2*sign_)-1),:);
    v3Y_=data((5-(idx_help+3*sign_)+1):(end-(idx_help+3*sign_)-1),:);
    v4Y_=data((5-(idx_help+4*sign_)+1):(end-(idx_help+4*sign_)-1),:);
    v5Y_=data((5-(idx_help+5*sign_)+1):(end-(idx_help+5*sign_)-1),:);
% toc

% tic
%     v1Y_=data; v1Y_(:,(end-(idx_help+sign_)):end)=[]; v1Y_(:,1:(5-(idx_help+sign_)))=[];
%     v2Y_=data; v2Y_(:,(end-(idx_help+2*sign_)):end)=[]; v2Y_(:,1:(5-(idx_help+2*sign_)))=[];
%     v3Y_=data; v3Y_(:,(end-(idx_help+3*sign_)):end)=[]; v3Y_(:,1:(5-(idx_help+3*sign_)))=[];
%     v4Y_=data; v4Y_(:,(end-(idx_help+4*sign_)):end)=[]; v4Y_(:,1:(5-(idx_help+4*sign_)))=[];
%     v5Y_=data; v5Y_(:,(end-(idx_help+5*sign_)):end)=[]; v5Y_(:,1:(5-(idx_help+5*sign_)))=[];
% toc % Elapsed time is 0.190144 seconds.


    v1Y=v1Y_; v2Y=v2Y_; v3Y=v3Y_; v4Y=v4Y_; v5Y=v5Y_; % normally matlab will act by pointer...

% toc
end
data_x_wenoY_1 = v1Y/3 - 7*v2Y/6 + 11*v3Y/6;
data_x_wenoY_2 = -v2Y/6 + 5*v3Y/6 + v4Y/3;
data_x_wenoY_3 = v3Y/3 + 5*v4Y/6 - v5Y/6;

 % 0.7
epsilon_helper=max(v1Y.^2,v2Y.^2);
epsilon_helper2=max(epsilon_helper,v3Y.^2);
epsilon_helper=max(epsilon_helper2,v4Y.^2);
epsilon_helper2=max(epsilon_helper,v5Y.^2);
epsilon = 1e-6*epsilon_helper2+ 1e-99;


S1 = (13/12)*(v1Y-2*v2Y+v3Y).^2 ...
    + 0.25*(v1Y-4*v2Y+3*v3Y).^2;
S2 = (13/12)*(v2Y-2*v3Y+v4Y).^2 ...
    + 0.25*(v2Y-v4Y).^2;
S3 = (13/12)*(v3Y-2*v4Y+v5Y).^2 ...
    + 0.25*(3*v3Y-4*v4Y+v5Y).^2;
% toc


%else
% tic
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % use IPPL on intel processor!
% % compared this implementation to previous verison and only rounding differences (~1e-16 relatively)
% if sign_>0
%     data_x_wenoY_1=imfilter(data,[0; 0; 0; 11/6; -7/6; 1/3;],'corr'); data_x_wenoY_1(1:2,:)=[]; data_x_wenoY_1((end-3):end,:)=[];%drop six last lines 
%     data_x_wenoY_2=imfilter(data,[0; 0; 1/3; 5/6; -1/6; 0;],'corr'); data_x_wenoY_2(1:2,:)=[]; data_x_wenoY_2((end-3):end,:)=[];%drop six last lines 
%     data_x_wenoY_3=imfilter(data,[0; -1/6; 5/6; 1/3; 0; 0;] ,'corr'); data_x_wenoY_3(1:2,:)=[]; data_x_wenoY_3((end-3):end,:)=[];%drop six last lines 
% else
%     data_x_wenoY_1=imfilter(data,[1/3; -7/6; 11/6; 0; 0; ],'corr'); data_x_wenoY_1(1:2,:)=[]; data_x_wenoY_1((end-3):end,:)=[];%drop six last lines 
%     data_x_wenoY_2=imfilter(data,[0; -1/6; 5/6; 1/3; 0;],'corr'); data_x_wenoY_2(1:2,:)=[]; data_x_wenoY_2((end-3):end,:)=[];%drop six last lines 
%     data_x_wenoY_3=imfilter(data,[0; 0; 1/3; 5/6; -1/6;],'corr'); data_x_wenoY_3(1:2,:)=[]; data_x_wenoY_3((end-3):end,:)=[];%drop six last lines 
% end
% %%
% 
% % tic % 0.40
% % epsilon = 1e-6*colfilt(diff(data_,1,1).^2,[5 1],'sliding',@max)+ 1e-99; epsilon((end-4):end,:)=[];%drop six last lines
% % toc
% 
% % checked and ok below
%   %0.7
% data2=data.^2;
% if sign_>0
%     data2(1,:)=[];
% else
%     data2(end,:)=[];
% end
% data3=data2(1:(end-5),:);
% for ii_=4:-1:1
%     data2(1,:)=[];
%     data3=max(data3,data2(1:(end-ii_),:));
% end
% 
% epsilon = 1e-6*data3+ 1e-99;
% % epsilon=reshape(epsilon,size(data)-[6 0]);
%  
% %end
% %%
% % checked and ok just numerical rounding errors
% if sign_>0
%     S1=(13/12)*imfilter(data,[0; 0; 0; 1; -2; 1;  ],'corr').^2+...
%         0.25*imfilter(data,[0; 0; 0; 3; -4; 1; ],'corr').^2; S1(1:2,:)=[]; S1((end-3):end,:)=[];%drop six last lines
%     S2=(13/12)*imfilter(data,[0; 0; 1; -2; 1; 0; ],'corr').^2+...
%         0.25*imfilter(data,[0; 0; -1; 0; 1; 0; ],'corr').^2; S2(1:2,:)=[]; S2((end-3):end,:)=[];%drop six last lines
%     S3=(13/12)*imfilter(data,[0; 1; -2; 1; 0; 0; ],'corr').^2+...
%         0.25*imfilter(data,[0; 1; -4; 3; 0; 0; ],'corr').^2; S3(1:2,:)=[]; S3((end-3):end,:)=[];%drop six last lines
% else
%         S1=(13/12)*imfilter(data,[1; -2; 1; 0; 0; ],'corr').^2+...
%         0.25*imfilter(data,[1; -4; 3; 0; 0; ],'corr').^2; S1(1:2,:)=[]; S1((end-3):end,:)=[];%drop six last lines
%     S2=(13/12)*imfilter(data,[0; 1; -2; 1; 0; ],'corr').^2+...
%         0.25*imfilter(data,[0; 1; 0; -1; 0; ],'corr').^2; S2(1:2,:)=[]; S2((end-3):end,:)=[];%drop six last lines
%     S3=(13/12)*imfilter(data,[0; 0; 1; -2; 1; ],'corr').^2+...
%         0.25*imfilter(data,[0; 0; 3; -4; 1; ],'corr').^2; S3(1:2,:)=[]; S3((end-3):end,:)=[];%drop six last lines
% end
% % epsilon and SY have 6 rows less than data and same number of columns
% % toc

alpha1 = 0.1./((S1+epsilon).^2);
alpha2 = 0.6./((S2+epsilon).^2);
alpha3 = 0.3./((S3+epsilon).^2);
a_total = alpha1+alpha2+alpha3;

% idx_iY2=true(size(data_x_wenoY));
% idx_iY2(1:3,:)=false;
% idx_iY2((end-2):end,:)=false;
% tic
% data_x_wenoY(4:(end-3),:) = (alpha1./a_total).*data_x_wenoY_1 + (alpha2./a_total).*data_x_wenoY_2 ...
%     + (alpha3./a_total).*data_x_wenoY_3;
% toc

% this one is slightly better than above (0.11 versus 0.13)
%  tic % ~0.10s
% data_x_wenoY=cat(1,zeros(3,size(data,2)),(alpha1./a_total).*data_x_wenoY_1 + (alpha2./a_total).*data_x_wenoY_2 ...
%     + (alpha3./a_total).*data_x_wenoY_3,zeros(3,size(data,2)));
% toc

% % this second one is 10x longer with reshape and equivalent if not to above
% tic
% data_x_wenoY=cat(1,zeros(3*size(data,2),1), (alpha1(:)./a_total(:)).*data_x_wenoY_1(:) + (alpha2(:)./a_total(:)).*data_x_wenoY_2(:) ...
%     + (alpha3(:)./a_total(:)).*data_x_wenoY_3(:), zeros(3*size(data,2),1));
% data_x_wenoY=reshape(data_x_wenoY,size(data));
% toc

% tic % ~ 0.6 s
result=(alpha1./a_total).*data_x_wenoY_1 + (alpha2./a_total).*data_x_wenoY_2+ (alpha3./a_total).*data_x_wenoY_3;
data_x_wenoY = zeros(size(data));
data_x_wenoY(4:(end-3),:) =result;
% toc
% data_x_wenoY(i+3) = data_x(i+3);
%%
