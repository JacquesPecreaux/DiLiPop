function [Cxm,Cym,dl0m]=boundary_conditions(Cxm,Cym,Psize,shift,dl0m,param_set)
global param;
    Cxm(1:shift,1)=Cxm((Psize+1):(Psize+shift),1); Cym(1:shift,1)=Cym((Psize+1):(Psize+shift),1);
    Cxm((Psize+shift+1):(Psize+2*shift),1)=Cxm((shift+1):(2*shift),1); Cym((Psize+shift+1):(Psize+2*shift),1)=Cym((shift+1):(2*shift),1);
    if nargout>=3 && nargin>=5 && ~isempty(dl0m)
        if ~isfield(param.(param_set),'fixed_length') || isempty(param.(param_set).fixed_length)
            dl0m(1:shift)=dl0m((Psize+1):(Psize+shift));
            dl0m((Psize+shift+1):(Psize+2*shift))=dl0m((shift+1):(2*shift));
        end
    end
