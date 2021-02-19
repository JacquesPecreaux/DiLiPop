function result=derX_cent4(data,dx)
    result=zeros(size(data));
    result(:,4:(end-3))=(-data(:,6:(end-1))+8*data(:,5:(end-2))-8*data(:,3:(end-4))+data(:,2:(end-5)))/(12*dx);
end
    