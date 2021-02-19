function [param_]=load_var(varargin)
    global param;
%     global general_param;
%     global status;
    param_=load_var_sub(varargin{:});
    param=param_;
%     general_param=general_param_;
end


