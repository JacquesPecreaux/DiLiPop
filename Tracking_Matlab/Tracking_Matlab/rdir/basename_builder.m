function name = basename_builder(param_)
    global param;
    if nargin<1
        param_=param;
    end
    name=fullfile(param_.basepath,short_name(param_),sprintf('%s_',param_.stem_name));
    name=name(1:(length(name)-1));
end