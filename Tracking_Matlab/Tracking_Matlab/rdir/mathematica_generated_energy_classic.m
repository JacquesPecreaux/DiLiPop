function [Ekappa,Esigma,Edl,Ein,Eout]=mathematica_generated_energy_classic(x,dx,dxx,dxxx,dxxxx,y,dy,dyy,dyyy,dyyyy,dl0m,ddl0m,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,c1,c2)
    % Ekappa = (dxx.^2+dyy.^2).*kappa.*lambda;
    % 
    % Esigma = (dx.^2+dy.^2).*lambda.*sigma;
    % 
    % % Edl = dy.*IntegratePerso(@(ix,k)lambdaInside.*(c1+(-1).*ImageF(ix,y(k)))+(-1).*lambdaOutside.*(c2+ ...
    % %   (-1).*ImageF(ix,y(k))),1,x);
    % Ein=dy.*IntegratePerso(@(ix,k)(lambdaInside.*(c1+(-1).*ImageF(ix,y(k))))^2,1,x);
    % Eout1=dy.*IntegratePerso(@(ix,k)(lambdaOutside.*(c2+(-1).*ImageF(ix,y(k))))^2,1,x);
    % Eout2=dy.*IntegratePerso(@(ix,k)(lambdaOutside.*(c2+(-1).*ImageF(ix,y(k))))^2,1,x);
    % Edl=Ein+Eout;

    Esigma=sum((1/2).*sigma.*sqrt(((-1).*dl0m+sqrt(dx.^2+dy.^2)).^2));
    Ekappa=sum(2.*kappa.*(dx.^2+dy.^2).^(-5/2).*((-1).*dy.*dxx+dx.*dyy).^2);

    
    global Imagee;
    I=Imagee(size(Imagee,1):-1:1,:);
    BW = roipoly(I,x,y); % rows and columns ok
    Iin=I(BW);
    Iout=I(~BW);
    Ein=sum((Iin(:)-c1).^2);
    Eout=sum((Iout(:)-c2).^2);
    Edl=lambdaInside*Ein+lambdaOutside*Eout;
end