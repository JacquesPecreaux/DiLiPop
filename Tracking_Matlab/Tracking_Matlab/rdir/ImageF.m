function [result]=ImageF(xx,yy)
global Imagee


result=interp2(Imagee,yy,xx,'*linear',0);
% stupid plaid format (meshgrid