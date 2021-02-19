function [Ekappa,Esigma,Edl,Ein,Eout,Econ]=mathematica_generated_Band_Energy(x,dx,dxx,dxxx,dxxxx,y,dy,dyy,dyyy,dyyyy,dl0m,ddl0m,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,lambdaContour,c1,c2,c3,BandWidth)
global Imagee
[Iin,Iout]=inside_outside_pixels(x,y);
[Icon]=coutour_pixels(x,y,Bandwidth);
Ekappa = sum(2.*(dx.^2+dy.^2).^(-5/2).*(dxx.*dy+(-1).*dx.*dyy).^2.*kappa);
Esigma = sum((1/2).*dl0m.^2.*sigma+(1/2).*dx.^2.*sigma+(1/2).*dy.^2.*sigma+(-1) ...
  .*dl0m.*(dx.^2+dy.^2).^(1/2).*sigma);
Ein = sum(Iin(:).*(1-Icon(:)).*(Imagee(:)-c1).^2);
Eout = sum(Iout(:).*(1-Icon(:)).*(Imagee(:)-c2).^2);
Econ = sum(Icon(:).*(Imagee(:)-c3).^2);
Edl = lambdaInside*Ein+lambdaOutside*Eout+lambdaContour*Econ;
end