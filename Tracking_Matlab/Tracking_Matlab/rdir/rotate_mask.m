function [ maskedStack_rotated ] = rotate_mask(maskedStack)

% enable to rotate the image in order to have the embryo along its
% long axis horizontal
% wish to have the posterior side on teh right

global param;

for k =  1 :length(maskedStack(1, 1, :)) 
    
    I_ = maskedStack(:,:,k);
    Ir=imrotate(I_,param.alpha);
    maskedStack_rotated(:,:,k) = logical(Ir);
    
end


end
