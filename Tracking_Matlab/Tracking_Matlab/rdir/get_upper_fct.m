function upper_fct_=get_upper_fct
        top_m_file=get_call_stack;
        if length(top_m_file)>1
            upper_fct_=top_m_file(end).name;
        else
            upper_fct_='base';
        end
end