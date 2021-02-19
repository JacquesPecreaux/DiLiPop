function [data_x] = der_ENO2_minusv(data, dx)
%
% Calculates the derivative (minus) using
% second order accurate ENO scheme
% takes 1-D data
% data: input data
% dx: grid resolution
% Note: before entering this function, data needs to be 
% extended by 2 at the beginning and end (values don't matter)
%
% Author: Baris Sumengen  sumengen@ece.ucsb.edu
% http://vision.ece.ucsb.edu/~sumengen/
%


data_x = zeros(size(data));

% extrapolate the beginning and end points of data
data(2,:) = 2*data(3,:)-data(4,:);
data(1,:) = 2*data(2,:)-data(3,:);
data(end-1,:) = 2*data(end-2,:)-data(end-3,:);
data(end,:) = 2*data(end-1,:)-data(end-2,:);

%Generate the divided difference tables
%ignoring division by dx for efficiency
D1=nan(size(data)); % to ensure the same shape as data and F
D1_=diff(data,1,1);
D1(1:(size(data,1)-1),:)=D1_;
% ignoring division by dx since this will cancel out
% D2 = (D1(2:end)-D1(1:end-1))/2;
D2=nan(size(data));
D2(1:(size(data,1)-2),:)=diff(D1_,1,1)/2;
absD2 = abs(D2);
%%
% global idx_1;
% if 0
    idx_1=(3:(size(data,1)-2))'*ones(1,size(data,2))+ones(size(data,1)-4,1)*((0:(size(data,2)-1))*(size(data,1)));
% end
    
%     if size(data,1)==1
%         idx_1=(3:(length(data)-2));
%     else
%         idx_1=(3:(length(data)-2))';
%     end
    
%     idx_1=idx(F(idx)~=0); % this one corresponds to i+2
% F is one everywhere

%     DmDp=(F(idx_1)>0); DmDp=1 everywhere !
    kp2=idx_1-1; % that's k+2
%     c=D2(kp2-(absD2(kp2-1) <= absD2(kp2)));
    % Q1p is D1(kp2)
%     Q2p=c.*(2*DmDp-1);
    data_x(idx_1)=D1(kp2)+D2(kp2-(absD2(kp2-1) <= absD2(kp2)));
    data_x(idx_1)=data_x(idx_1)/dx;   
    % checked and correct with random force on June 16th 2009


if 0
    for i=1:(length(data)-4)
        k = i-1;

        Q1p = D1(k+2); %D1k_half;

        if absD2(k+1) <= absD2(k+2) %|D2k| <= |D2kp1|
            c = D2(k+1); %D2k;
        else
            c = D2(k+2); %D2kp1;
        end

        % ignoring multiplication by dx since this will also cancel out
        Q2p = c*(2*(i-k)-1);

        data_x(i+2) = Q1p+Q2p;
        data_x(i+2) = data_x(i+2)/dx;
    end
end








