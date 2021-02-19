function [general_param_]=load_var_general(varargin)
    global general_param;
%     global general_param;
%     global status;
    general_param_=load_var_sub(varargin{:});
    general_param=general_param_;
%     general_param=general_param_;
end


