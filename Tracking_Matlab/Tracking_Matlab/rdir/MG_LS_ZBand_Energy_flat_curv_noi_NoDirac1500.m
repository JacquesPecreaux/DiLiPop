function [Ekappa,Esigma,Edl,Ein,Eout,Econ]=MG_LS_Band_Energy_flat_curv(Der,LevelSetFct,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,lambdaContour,c1,c2,c3,epsilon,BandWidth,dl0m,Der2)
global Imagee
beta=epsilon;
Ekappa = (-1).*beta.^(-1).*kappa.*(Der(:,:,3)+Der(:,:,5)).^2.*HeavisideTheta(( ...
  -1/2).*beta+LevelSetFct)+beta.^(-1).*kappa.*(Der(:,:,3)+Der(:,:,5)) ...
  .^2.*HeavisideTheta((1/2).*beta+LevelSetFct);
Esigma = (-1).*beta.^(-1).*sigma.*HeavisideTheta((-1/2).*beta+LevelSetFct)+ ...
  beta.^(-1).*sigma.*HeavisideTheta((1/2).*beta+LevelSetFct);
Ein = lambdaInside.*HeavisideTheta((-1).*BandWidth+LevelSetFct);
Eout = (c2+(-1).*Imagee).^2+(-1).*(c2+(-1).*Imagee).^2.* ...
  HeavisideThetaApprox(LevelSetFct,epsilon);
Econ = (c3+(-1).*Imagee).^2.*HeavisideThetaApprox(LevelSetFct,epsilon);
Edl = lambdaOutside*Eout+lambdaContour*Econ;
end