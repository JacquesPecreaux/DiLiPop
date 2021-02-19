function [result]=DiracDelta(X)
global param;
[result]=DiracDeltaApprox(X,param.epsilon);