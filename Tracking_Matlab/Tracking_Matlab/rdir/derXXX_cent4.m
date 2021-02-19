function result=derXXX_cent4(data,dx)
    result=zeros(size(data));
    result(:,4:(end-3))=(-data(:,7:end)+8*data(:,6:(end-1))-13*data(:,5:(end-2))+13*data(:,3:(end-4))-8*data(:,2:(end-5))+data(:,1:(end-6)))/(8*dx^3);
end
