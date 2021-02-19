function [der] = select_der_normal(Vn, der_minus, der_plus)
%
% Under a force in the normal direction,
% select a derivative value given (plus) and (minus) derivatives.
%
% Author: Baris Sumengen  sumengen@ece.ucsb.edu
% http://vision.ece.ucsb.edu/~sumengen/
%

if any(size(der_minus) ~= size(der_plus)) || any(size(der_plus) ~= size(Vn))
    error('plus, minus derivative vectors and normal force (Vn) need to be of equal length!');
end

der = zeros(size(der_plus));
%%
Vn_der_m=Vn.*der_minus;
Vn_der_p=Vn.*der_plus;
idx=((Vn_der_m <= 0) & (Vn_der_p <= 0));
der(idx)=der_plus(idx);
idx=((Vn_der_m <= 0) & (Vn_der_p >= 0));
der(idx)=der_minus(idx);
der((Vn_der_m <= 0) & (Vn_der_p >= 0))=0;
idx=((Vn_der_m >= 0) & (Vn_der_p <= 0));
idx2=(abs(Vn_der_p) >= abs(Vn_der_m));
der(idx & idx2)=der_minus(idx & idx2);
der(idx & ~idx2)=der_minus(idx & ~idx2);
% checked and correct with random force on June 11th 2009





