function [result]=MG_LS_Band(Der,LevelSetFct,lambda,kappa,sigma,extensionmax,lambdaInside,lambdaOutside,lambdaContour,c1,c2,c3,Imagee,ImageeDer,epsilon,BandWidth,dl0m)
idx_flat=Der(:,:,1).^2+Der(:,:,2).^2;
if kappa==0 || lambda==0
result1=zeros(size(LevelSetFct));
else
result1 = 2.*kappa.*lambda.*Der(:,:,2).^6.*(Der(:,:,1).^2+Der(:,:,2).^2).^(-5).*((-3) ...
  .*Der(:,:,3).^3+18.*Der(:,:,3).*Der(:,:,4).^2+(-6).*Der(:,:,3).* ...
  Der(:,:,7).*Der(:,:,2)+(-6).*Der(:,:,6).*Der(:,:,4).*Der(:,:,2)+ ...
  Der(:,:,10).*Der(:,:,2).^2+3.*Der(:,:,3).^2.*Der(:,:,5))+4.*kappa.* ...
  lambda.*Der(:,:,1).*Der(:,:,2).^5.*(Der(:,:,1).^2+Der(:,:,2).^2).^(-5).*(30.* ...
  Der(:,:,3).^2.*Der(:,:,4)+(-18).*Der(:,:,4).^3+15.*Der(:,:,7).*Der(:,:,4).* ...
  Der(:,:,2)+Der(:,:,2).*((-2).*Der(:,:,11).*Der(:,:,2)+3.*Der(:,:,6).* ...
  Der(:,:,5))+(-6).*Der(:,:,3).*(Der(:,:,6).*Der(:,:,2)+(-1).*Der(:,:,8).* ...
  Der(:,:,2)+4.*Der(:,:,4).*Der(:,:,5)))+(-4).*kappa.*lambda.*Der(:,:,1).^7.*( ...
  Der(:,:,1).^2+Der(:,:,2).^2).^(-5).*(2.*Der(:,:,13).*Der(:,:,2)+3.* ...
  Der(:,:,8).*Der(:,:,5)+3.*Der(:,:,4).*Der(:,:,9))+(-4).*kappa.*lambda.* ...
  Der(:,:,1).^3.*Der(:,:,2).^3.*(Der(:,:,1).^2+Der(:,:,2).^2).^(-5).*(42.* ...
  Der(:,:,3).^2.*Der(:,:,4)+(-60).*Der(:,:,4).^3+6.*Der(:,:,3).*(Der(:,:,6).* ...
  Der(:,:,2)+Der(:,:,8).*Der(:,:,2)+(-16).*Der(:,:,4).*Der(:,:,5))+Der(:,:,2).*( ...
  4.*Der(:,:,11).*Der(:,:,2)+2.*Der(:,:,13).*Der(:,:,2)+(-15).*Der(:,:,8).* ...
  Der(:,:,5))+Der(:,:,4).*(6.*Der(:,:,7).*Der(:,:,2)+42.*Der(:,:,5).^2+(-9).* ...
  Der(:,:,2).*Der(:,:,9)))+(-4).*kappa.*lambda.*Der(:,:,1).^5.*Der(:,:,2).*( ...
  Der(:,:,1).^2+Der(:,:,2).^2).^(-5).*(18.*Der(:,:,4).^3+Der(:,:,2).*(12.* ...
  Der(:,:,3).*Der(:,:,8)+2.*Der(:,:,11).*Der(:,:,2)+4.*Der(:,:,13).* ...
  Der(:,:,2)+3.*Der(:,:,6).*Der(:,:,5)+(-12).*Der(:,:,8).*Der(:,:,5))+3.* ...
  Der(:,:,4).*(7.*Der(:,:,7).*Der(:,:,2)+8.*Der(:,:,3).*Der(:,:,5)+(-10).* ...
  Der(:,:,5).^2+(-2).*Der(:,:,2).*Der(:,:,9)))+2.*kappa.*lambda.* ...
  Der(:,:,1).^2.*Der(:,:,2).^4.*(Der(:,:,1).^2+Der(:,:,2).^2).^(-5).*(21.* ...
  Der(:,:,3).^3+(-45).*Der(:,:,3).^2.*Der(:,:,5)+2.*(6.*Der(:,:,6).* ...
  Der(:,:,4).*Der(:,:,2)+(-21).*Der(:,:,4).*Der(:,:,8).*Der(:,:,2)+51.* ...
  Der(:,:,4).^2.*Der(:,:,5)+Der(:,:,2).*(Der(:,:,10).*Der(:,:,2)+3.* ...
  Der(:,:,12).*Der(:,:,2)+(-12).*Der(:,:,7).*Der(:,:,5)))+(-6).*Der(:,:,3).* ...
  (28.*Der(:,:,4).^2+(-4).*Der(:,:,7).*Der(:,:,2)+(-4).*Der(:,:,5).^2+ ...
  Der(:,:,2).*Der(:,:,9)))+2.*kappa.*lambda.*Der(:,:,1).^8.*(Der(:,:,1).^2+ ...
  Der(:,:,2).^2).^(-5).*Der(:,:,14)+2.*kappa.*lambda.*Der(:,:,1).^4.* ...
  Der(:,:,2).^2.*(Der(:,:,1).^2+Der(:,:,2).^2).^(-5).*(18.*Der(:,:,6).* ...
  Der(:,:,4).*Der(:,:,2)+(-12).*Der(:,:,4).*Der(:,:,8).*Der(:,:,2)+ ...
  Der(:,:,10).*Der(:,:,2).^2+12.*Der(:,:,12).*Der(:,:,2).^2+24.* ...
  Der(:,:,3).^2.*Der(:,:,5)+(-168).*Der(:,:,4).^2.*Der(:,:,5)+(-12).* ...
  Der(:,:,7).*Der(:,:,2).*Der(:,:,5)+21.*Der(:,:,5).^3+3.*Der(:,:,3).*(34.* ...
  Der(:,:,4).^2+10.*Der(:,:,7).*Der(:,:,2)+(-15).*Der(:,:,5).^2)+(-12).* ...
  Der(:,:,2).*Der(:,:,5).*Der(:,:,9)+Der(:,:,2).^2.*Der(:,:,14))+2.*kappa.* ...
  lambda.*Der(:,:,1).^6.*(Der(:,:,1).^2+Der(:,:,2).^2).^(-5).*(30.*Der(:,:,4).* ...
  Der(:,:,8).*Der(:,:,2)+6.*Der(:,:,12).*Der(:,:,2).^2+18.*Der(:,:,4).^2.* ...
  Der(:,:,5)+12.*Der(:,:,7).*Der(:,:,2).*Der(:,:,5)+3.*Der(:,:,3).* ...
  Der(:,:,5).^2+(-3).*Der(:,:,5).^3+6.*Der(:,:,3).*Der(:,:,2).*Der(:,:,9)+( ...
  -12).*Der(:,:,2).*Der(:,:,5).*Der(:,:,9)+2.*Der(:,:,2).^2.*Der(:,:,14));

% result1(abs(DiracDeltaPrimeApprox(LevelSetFct,epsilon))<1e-4)=0;
result1(idx_flat==0)=0;

end

if sigma==0 || lambda==0
result2=zeros(size(LevelSetFct));
else
result2 = 2.*BandWidth.*lambda.*LevelSetFct.*(BandWidth.^2+LevelSetFct.^2) ...
  .^(-2).*(Der(:,:,1).^2+Der(:,:,2).^2).*pi.^(-1).*sigma+(-2).* ...
  BandWidth.^3.*lambda.*(BandWidth.^2+LevelSetFct.^2).^(-2).*( ...
  Der(:,:,3)+Der(:,:,5)).*pi.^(-1).*sigma+(-2).*BandWidth.*lambda.* ...
  LevelSetFct.^2.*(BandWidth.^2+LevelSetFct.^2).^(-2).*(Der(:,:,3)+ ...
  Der(:,:,5)).*pi.^(-1).*sigma;

% result2(abs(DiracDeltaApprox(LevelSetFct,epsilon))<1e-4)=0;
end

result3 = result1+result2+c3.^2.*lambdaContour.*DiracDeltaApprox(LevelSetFct,epsilon)+(-2).* ...
  c3.*Imagee.*lambdaContour.*DiracDeltaApprox(LevelSetFct,epsilon)+ ...
  Imagee.^2.*(lambdaContour+(-1).*lambdaOutside).*DiracDeltaApprox( ...
  LevelSetFct,epsilon)+(-1).*c2.^2.*lambdaOutside.*DiracDeltaApprox( ...
  LevelSetFct,epsilon)+2.*c2.*Imagee.*lambdaOutside.* ...
  DiracDeltaApprox(LevelSetFct,epsilon);

result3(idx_flat==0)=0;
result = result1+result2+result3;
end