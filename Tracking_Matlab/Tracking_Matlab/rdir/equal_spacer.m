function [Cxm_h,Cym_h,dl0m_h]=equal_spacer(length_,Psize,Cxm,Cym,dl0m,param_set)
% used for active contour but can be used in general, Psize is the expected
% number of point
    global param;

    Cxm=reshape(Cxm,[length(Cxm) 1]);
    Cym=reshape(Cym,[length(Cym) 1]);
    Cxm_=Cxm; Cxm_(length(Cxm_)+1)=Cxm_(1);
    Cym_=Cym; Cym_(length(Cym_)+1)=Cym_(1);
    if nargout>=3 && nargin>=5 && ~isempty(dl0m)
        if ~isfield(param.(param_set),'fixed_length') || isempty(param.(param_set).fixed_length)
            dl0m_=dl0m; dl0m_(length(dl0m)+1)=dl0m_(1); %robust to geometry column or line vector
        else
            dl0m_h=dl0m;
        end
    end

    if isempty(length_)
        dxa=diff(Cxm_); dya=diff(Cym_);
        length_=sqrt(dxa.^2+dya.^2);
    end

    length0=sum(length_)/Psize; % contour is closed!
    index=2;
    length_to_index=length_(1);
    Cxm_h=Cxm(1:min(Psize,length(Cxm)),1);
    Cym_h=Cym(1:min(Psize,length(Cym)),1);
    if nargout>=3 && nargin>=5 && ~isempty(dl0m)
        if ~isfield(param.(param_set),'fixed_length') || isempty(param.(param_set).fixed_length)
            dl0m_h=dl0m;
        end
    end
    % if Cxm_h is shorter, is get longer in this loop
    for i=1:(Psize-1)
        while ((i*length0)>length_to_index)
            index=index+1;
            length_to_index=length_to_index+length_(index-1); %length to the point index
        end
        alpha=(length_to_index-i*length0)/length_(index-1);
        Cxm_h(i+1)=alpha*Cxm_(index-1,1)+(1-alpha)*Cxm_(index,1); Cym_h(i+1)=alpha*Cym_(index-1,1)+(1-alpha)*Cym_(index,1);
        if nargout>=3 && nargin>=5 && ~isempty(dl0m)
            if ~isfield(param.(param_set),'fixed_length') || isempty(param.(param_set).fixed_length)
                dl0m_h(i+1)=alpha*dl0m_(index-1)+(1-alpha)*dl0m_(index);
            end
        end
    end
end
