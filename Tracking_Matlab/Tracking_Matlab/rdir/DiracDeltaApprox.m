function [result]=DiracDeltaApprox(X,epsilon)
result = epsilon.^(-1).*pi.^(-1).*(1+epsilon.^(-2).*X.^2).^(-1);

end