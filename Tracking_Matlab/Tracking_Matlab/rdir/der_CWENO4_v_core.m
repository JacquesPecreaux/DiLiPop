function [data_x_wenoY] = der_CWENO4_v_core(data_, dx,dummy,x_yes_or_y_no)
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
% padding by 2 only
data_(3,:) = 2*data_(4,:)-data_(5,:); % OK CWENO4 %
data_(2,:) = 2*data_(3,:)-data_(4,:); % OK CWENO4 %
data_(1,:) = 2*data_(2,:)-data_(3,:); % OK CWENO4 %
data_(end-2,:) = 2*data_(end-3,:)-data_(end-4,:); % OK CWENO4 %
data_(end-1,:) = 2*data_(end-2,:)-data_(end-3,:); % OK CWENO4 %
data_(end,:) = 2*data_(end-1,:)-data_(end-2,:); % OK CWENO4 %

data=cat(1,diff(data_,1,1)/dx,nan(1,size(data_,2))); % OK CWENO4 %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sign_=-1; % OK CWENO4 % % just to re-use the code
idx_help=5; % OK CWENO4 %
% because the shift is 3, I have to start at 2
% because of the padding index 2 is in fact -2 (padding by 3)    
if x_yes_or_y_no % IDENTICAL BUT DIFFER IN SIZE, THIS TRICK TO NOT CHANGE ALLOCATION IN TANDEM WITH PERSISTENT
    v1X_=data((5-(idx_help+sign_)+1):(end-(idx_help+sign_)-1),:); % OK CWENO4 %
    v2X_=data((5-(idx_help+2*sign_)+1):(end-(idx_help+2*sign_)-1),:); % OK CWENO4 %
    v3X_=data((5-(idx_help+3*sign_)+1):(end-(idx_help+3*sign_)-1),:); % OK CWENO4 %
    v4X_=data((5-(idx_help+4*sign_)+1):(end-(idx_help+4*sign_)-1),:); % OK CWENO4 %
    v5X_=data((5-(idx_help+5*sign_)+1):(end-(idx_help+5*sign_)-1),:); % OK CWENO4 %
    
    v1Y=v1X_; v2Y=v2X_; v3Y=v3X_; v4Y=v4X_; v5Y=v5X_; % OK CWENO4 % % normally matlab will act by pointer...
else
    v1Y_=data((5-(idx_help+sign_)+1):(end-(idx_help+sign_)-1),:);% OK CWENO4 %
    v2Y_=data((5-(idx_help+2*sign_)+1):(end-(idx_help+2*sign_)-1),:);% OK CWENO4 %
    v3Y_=data((5-(idx_help+3*sign_)+1):(end-(idx_help+3*sign_)-1),:);% OK CWENO4 %
    v4Y_=data((5-(idx_help+4*sign_)+1):(end-(idx_help+4*sign_)-1),:);% OK CWENO4 %
    v5Y_=data((5-(idx_help+5*sign_)+1):(end-(idx_help+5*sign_)-1),:);% OK CWENO4 %

    v1Y=v1Y_; v2Y=v2Y_; v3Y=v3Y_; v4Y=v4Y_; v5Y=v5Y_;% OK CWENO4 % % normally matlab will act by pointer...
end
data_x_wenoY_1 =  v1Y/2  -2*v2Y  +3*v3Y/2;% OK CWENO4 %
data_x_wenoY_2 = -v2Y/2          +v4Y/2;% OK CWENO4 %
data_x_wenoY_3 = -3*v3Y/2+2*v4Y-v5Y/2;% OK CWENO4 %

epsilon_helper=max(v1Y.^2,v2Y.^2);% OK CWENO4 %
epsilon_helper2=max(epsilon_helper,v3Y.^2);% OK CWENO4 %
epsilon_helper=max(epsilon_helper2,v4Y.^2);% OK CWENO4 %
epsilon_helper2=max(epsilon_helper,v5Y.^2);% OK CWENO4 %
epsilon = 1e-6*epsilon_helper2+ 1e-99;% OK CWENO4 %

S1 = (13/12)*(v1Y-2*v2Y+v3Y).^2 ...
    + 0.25*(v1Y-4*v2Y+3*v3Y).^2;% OK CWENO4 %
S2 = (13/12)*(v2Y-2*v3Y+v4Y).^2 ...
    + 0.25*(v2Y-v4Y).^2;% OK CWENO4 %
S3 = (13/12)*(v3Y-2*v4Y+v5Y).^2 ...
    + 0.25*(3*v3Y-4*v4Y+v5Y).^2;% OK CWENO4 %

alpha1 = (1/6)./((S1+epsilon).^2); % OK CWENO4 % % linear weight C1
alpha2 = (2/3)./((S2+epsilon).^2); % OK CWENO4 % % linear weight C2
alpha3 = (1/6)./((S3+epsilon).^2); % OK CWENO4 % % linear weight C3
a_total = alpha1+alpha2+alpha3;

result=(alpha1./a_total).*data_x_wenoY_1 + (alpha2./a_total).*data_x_wenoY_2+ (alpha3./a_total).*data_x_wenoY_3;
data_x_wenoY = zeros(size(data));
data_x_wenoY(4:(end-3),:) =result;
