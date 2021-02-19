function [count,X]=imhist_over(I,n)
    if (n>0)
        [count,X]=imhist(I,n);
    else
        [count,X]=imhist(I);
    end
    