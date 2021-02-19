function result=derXXXX_cent4(data,dx)
    result=zeros(size(data));
    result(:,4:(end-3))=(-data(:,7:end)+12*data(:,6:(end-1))-39*data(:,5:(end-2))+56*data(:,4:(end-3))-39*data(:,3:(end-4))+12*data(:,2:(end-5))-data(:,1:(end-6)))/(6*dx^4);
end
