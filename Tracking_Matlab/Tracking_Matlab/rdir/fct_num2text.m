function [text_]=fct_num2text(ind)
    if isnan(ind)
        text_='no_name';
    else
        function_text{1}='Tracking ';
        function_text{2}='Converting coordinates respect to embryo ';
        function_text{3}='Frequence analysis ';
        function_text{4}='Bio timing finder ';
        function_text{5}='Movie making ';
        function_text{6}='Spindle motion analysis ';
        function_text{7}='Reporting ';
        function_text{8}='Animated plot generation ';
        function_text{9}='Zoomed posterior Centrosome movie making ';
        function_text{10}='adding to histogram from file ';
        function_text{11}='active contour ';
        function_text{12}='meta analysis';
    %     function_text{14}='ana analysis';
        function_text{13}='cortex detection';
        function_text{16}='cortex analysis';
        function_text{15}='Finalise stats';
        function_text{17}='Sliding windows analysis';
        try
            text_=function_text{round(log(ind)/log(2))+1};
        catch
            text_='unknown reporter status';
        end
    end
end