function [Iin,Iout]=inside_outside_pixels(x,y)
    global Imagee;
    I=Imagee(size(Imagee,1):-1:1,:);
    BW = poly2mask(I,x,y); % rows and columns ok
    Iin=BW;
    Iout=~BW;
end
