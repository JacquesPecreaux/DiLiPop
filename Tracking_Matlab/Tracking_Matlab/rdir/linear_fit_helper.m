function [a,b,s_a,s_b,a_confidence_interv]=linear_fit_helper(frequence2,~)
    if size(frequence2,1)>2 % 2 seems not enough
        [res,res_stats]=robustfit(frequence2(:,1),frequence2(:,2));
        b=res(1); % offset
        a=res(2); % slope
        s_a=res_stats.se(2);
        s_b=res_stats.se(1);
    else
        a=0;
        s_a=0;
        b=0;
        s_b=0;
end
    a_confidence_interv=NaN; % deprecated 
end