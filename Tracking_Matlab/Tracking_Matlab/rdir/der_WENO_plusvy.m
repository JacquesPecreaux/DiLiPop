function [data_x_wenoY] = der_WENO_plusvy(data, dx)
[data_x_wenoY] = der_WENO_v_core(data, dx,1,0);
return


%
% Calculates the derivative (plus) using
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
global idx_iY;
if 0
    idx_iY=(1:(size(data,1)-6))'*ones(1,size(data,2))+ones(size(data,1)-6,1)*((0:(size(data,2)-1))*(size(data,1)));
end
global v1Y v2Y v3Y v4Y v5Y
persistent data_x_wenoY_1 data_x_wenoY_2 data_x_wenoY_3



data_x_wenoY = zeros(size(data));

% extrapolate the beginning and end points of data

%%
% extrapolate the beginning and end points of data
data(3,:) = 2*data(4,:)-data(5,:);
data(2,:) = 2*data(3,:)-data(4,:);
data(1,:) = 2*data(2,:)-data(3,:);
data(end-2,:) = 2*data(end-3,:)-data(end-4,:);
data(end-1,:) = 2*data(end-2,:)-data(end-3,:);
data(end,:) = 2*data(end-1,:)-data(end-2,:);

D1=nan(size(data)); % to ensure the same shape as data and F
D1_=diff(data,1,1);
D1(1:(size(data,1)-1),:)=D1_/dx;

% idx_iY=(1:(length(data)-6))*ones(1,size(data,2));
% idx_k=(1:(size(data,1)-6))*ones(1,size(data,2));



v1Y=D1(idx_iY+5);
v2Y=D1(idx_iY+4);
v3Y=D1(idx_iY+3);
v4Y=D1(idx_iY+2);
v5Y=D1(idx_iY+1);


data_x_wenoY_1 = v1Y/3 - 7*v2Y/6 + 11*v3Y/6;
data_x_wenoY_2 = -v2Y/6 + 5*v3Y/6 + v4Y/3;
data_x_wenoY_3 = v3Y/3 + 5*v4Y/6 - v5Y/6;

% vY and data_x_wenoY_Y have 6 rows less than data and same number of columns

tmp=cat(3,v1Y,v2Y,v3Y,v4Y,v5Y);
tmp2=tmp.^2;
epsilon = 1e-6*max(tmp2,[],3)+ 1e-99;


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
data_x_wenoY(4:(end-3),:) = (alpha1./a_total).*data_x_wenoY_1 + (alpha2./a_total).*data_x_wenoY_2 ...
    + (alpha3./a_total).*data_x_wenoY_3;

