function [result]=HeavisideTheta(X)
global param;
[result]=HeavisideThetaApprox(X,param.epsilon);