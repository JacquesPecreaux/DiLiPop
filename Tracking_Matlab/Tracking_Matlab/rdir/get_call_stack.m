function top_m_file=get_call_stack
    if isdeployed
        try
            error('Fake error to retrieve call stack');
        catch e
            top_m_file = e.stack;
        end
    else
        top_m_file=dbstack;
    end
%     disp('Found call stack')
%     for ii_=1:length(top_m_file)
%         disp(top_m_file(ii_).name);
%     end
end
