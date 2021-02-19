function [result]=HeavisideThetaApprox(X,epsilon)
result = (1/2).*(1+2.*pi.^(-1).*atan(epsilon.^(-1).*X));

end