function [result]=DiracDeltaPrimeApprox(X,epsilon)
result = (-2).*epsilon.^(-3).*pi.^(-1).*X.*(1+epsilon.^(-2).*X.^2).^(-2);

end