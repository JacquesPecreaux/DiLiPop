function result=derXX_cent4(data,dx)
    result=zeros(size(data));
    result(:,4:(end-3))=(-data(:,6:(end-1))+16*data(:,5:(end-2))-30*data(:,4:(end-3))+16*data(:,3:(end-4))-data(:,2:(end-5)))/(12*dx^2);
end
