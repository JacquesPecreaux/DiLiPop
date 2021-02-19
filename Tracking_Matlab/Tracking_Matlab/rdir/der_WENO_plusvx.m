function [data_x_wenoX] = der_WENO_plusvx(data, dx)
[data_x_wenoX] = der_WENO_v_core(data', dx,1,1)';
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
global data_x_wenoX;
global idx_iX;
if 0
    idx_iX=(1:(size(data,1)-6))'*ones(1,size(data,2))+ones(size(data,1)-6,1)*((0:(size(data,2)-1))*(size(data,1)));
end
global v1X v2X v3X v4X v5X
global data_x_wenoX_1 data_x_wenoX_2 data_x_wenoX_3



data_x_wenoX = zeros(size(data));

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

% idx_iX=(1:(length(data)-6))*ones(1,size(data,2));
% idx_k=(1:(size(data,1)-6))*ones(1,size(data,2));



v1X=D1(idx_iX+5);
v2X=D1(idx_iX+4);
v3X=D1(idx_iX+3);
v4X=D1(idx_iX+2);
v5X=D1(idx_iX+1);


data_x_wenoX_1 = v1X/3 - 7*v2X/6 + 11*v3X/6;
data_x_wenoX_2 = -v2X/6 + 5*v3X/6 + v4X/3;
data_x_wenoX_3 = v3X/3 + 5*v4X/6 - v5X/6;

% vX and data_x_wenoX_X have 6 rows less than data and same number of columns

tmp=cat(3,v1X,v2X,v3X,v4X,v5X);
tmp2=tmp.^2;
epsilon = 1e-6*max(tmp2,[],3)+ 1e-99;


S1 = (13/12)*(v1X-2*v2X+v3X).^2 ...
    + 0.25*(v1X-4*v2X+3*v3X).^2;
S2 = (13/12)*(v2X-2*v3X+v4X).^2 ...
    + 0.25*(v2X-v4X).^2;
S3 = (13/12)*(v3X-2*v4X+v5X).^2 ...
    + 0.25*(3*v3X-4*v4X+v5X).^2;


% epsilon and SX have 6 rows less than data and same number of columns

alpha1 = 0.1./((S1+epsilon).^2);
alpha2 = 0.6./((S2+epsilon).^2);
alpha3 = 0.3./((S3+epsilon).^2);
a_total = alpha1+alpha2+alpha3;

% idx_iX2=true(size(data_x_wenoX));
% idx_iX2(1:3,:)=false;
% idx_iX2((end-2):end,:)=false;
data_x_wenoX(4:(end-3),:) = (alpha1./a_total).*data_x_wenoX_1 + (alpha2./a_total).*data_x_wenoX_2 ...
    + (alpha3./a_total).*data_x_wenoX_3;

