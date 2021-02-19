function [data_x_wenoY] = der_WENO_minusvy(data, dx)
% if isempty(idx_iY) || any(size(idx_iY)~=any(size(data)- [6 0]))
%     idx_iY=(1:(size(data,1)-6))'*ones(1,size(data,2))+ones(size(data,1)-6,1)*((0:(size(data,2)-1))*(size(data,1)));
% end

[data_x_wenoY] = der_WENO_v_core(data, dx,-1,0);
return

persistent epsilon_helper epsilon_helper2;
persistent idx_k;
persistent epsilon;
persistent data_x_wenoY_1 data_x_wenoY_2 data_x_wenoY_3;
persistent S1 S2 S3;
persistent alpha1 alpha2 alpha3 a_total;
persistent v1Y v2Y v3Y v4Y v5Y;
global idx_iY;
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

% data_x_wenoY = zeros(size(data));

% extrapolate the beginning and end points of data

%%
% extrapolate the beginning and end points of data
data(3,:) = 2*data(4,:)-data(5,:);
data(2,:) = 2*data(3,:)-data(4,:);
data(1,:) = 2*data(2,:)-data(3,:);
data(end-2,:) = 2*data(end-3,:)-data(end-4,:);
data(end-1,:) = 2*data(end-2,:)-data(end-3,:);
data(end,:) = 2*data(end-1,:)-data(end-2,:);

% checked oct 8th with any(any(~(D1==data | (isnan(D1) & isnan(data)))))
if 0
D1=nan(size(data)); % to ensure the same shape as data and F
D1_=diff(data,1,1);
D1(1:(size(data,1)-1),:)=D1_/dx;
end
% speed improved from above
data=cat(1,diff(data,1,1)/dx,nan(1,size(data,2)));
%%
if 0

data(3) = 2*data(4)-data(5);
data(2) = 2*data(3)-data(4);
data(1) = 2*data(2)-data(3);
data(end-2) = 2*data(end-3)-data(end-4);
data(end-1) = 2*data(end-2)-data(end-3);
data(end) = 2*data(end-1)-data(end-2);

D1 = (data(2:end)-data(1:end-1))/dx;


end
%%

idx_k=idx_iY-1;
if 0
% tic
% this is a much faster solution than reporting indexes everywhere --
% indexing slow down computations
v1Y=data(idx_k+1);
v2Y=data(idx_k+2);
v3Y=data(idx_k+3);
v4Y=data(idx_k+4);
v5Y=data(idx_k+5);
% toc
end

% faster than above implementation (checked also for same result)
% tic
v1Y=data; v1Y((end-5):end,:)=[];
v2Y=data; v2Y((end-4):end,:)=[]; v2Y(1,:)=[];
v3Y=data; v3Y((end-3):end,:)=[]; v3Y(1:2,:)=[];
v4Y=data; v4Y((end-2):end,:)=[]; v4Y(1:3,:)=[];
v5Y=data; v5Y((end-1):end,:)=[]; v5Y(1:4,:)=[];
% toc

data_x_wenoY_1 = v1Y/3 - 7*v2Y/6 + 11*v3Y/6;
data_x_wenoY_2 = -v2Y/6 + 5*v3Y/6 + v4Y/3;
data_x_wenoY_3 = v3Y/3 + 5*v4Y/6 - v5Y/6;

if 0
    tic
% vY and data_x_wenoY_Y have 6 rows less than data and same number of columns
epsilon_helper=cat(3,v1Y,v2Y,v3Y,v4Y,v5Y);
epsilon_helper=epsilon_helper.^2;
epsilon = 1e-6*max(epsilon_helper,[],3)+ 1e-99;
toc
end

% tic
epsilon_helper=max(v1Y.^2,v2Y.^2);
epsilon_helper2=max(epsilon_helper,v3Y.^2);
epsilon_helper=max(epsilon_helper2,v4Y.^2);
epsilon_helper2=max(epsilon_helper,v5Y.^2);
epsilon = 1e-6*epsilon_helper2+ 1e-99;
% toc

S1 = (13/12)*(v1Y-2*v2Y+v3Y).^2 ...
    + 0.25*(v1Y-4*v2Y+3*v3Y).^2;
S2 = (13/12)*(v2Y-2*v3Y+v4Y).^2 ...
    + 0.25*(v2Y-v4Y).^2;
S3 = (13/12)*(v3Y-2*v4Y+v5Y).^2 ...
    + 0.25*(3*v3Y-4*v4Y+v5Y).^2;


% epsilon and SY have 6 rows less than data and same number of columns

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
% tic
data_x_wenoY=cat(1,zeros(3,size(data,2)),(alpha1./a_total).*data_x_wenoY_1 + (alpha2./a_total).*data_x_wenoY_2 ...
    + (alpha3./a_total).*data_x_wenoY_3,zeros(3,size(data,2)));
% toc

% % this second one is 10x longer with reshape and equivalent if not to above
% tic
% data_x_wenoY=cat(1,zeros(3*size(data,2),1), (alpha1(:)./a_total(:)).*data_x_wenoY_1(:) + (alpha2(:)./a_total(:)).*data_x_wenoY_2(:) ...
%     + (alpha3(:)./a_total(:)).*data_x_wenoY_3(:), zeros(3*size(data,2),1));
% data_x_wenoY=reshape(data_x_wenoY,size(data));
% toc

% data_x_wenoY(i+3) = data_x(i+3);
%%
