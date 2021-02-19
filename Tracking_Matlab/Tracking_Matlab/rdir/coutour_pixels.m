function [Icon]=coutour_pixels(x,y,Bandwidth)
    global Imagee;
    I=Imagee(size(Imagee,1):-1:1,:);
    Icon=ones(size(I));
    xmat=ones(size(I,1),1)*(1:size(I,2))';
    ymat=(size(I,1):-1:1)*ones(size(I,2));
    for ii_=1:length(x)
        dist=sqrt((xmat-x(ii_)).^2+(ymat-y(ii_)).^2);
        Icon=Icon*DiracDeltaApprox(dist,Bandwidth);
    end
end
