function res=imtophat_preprocess(I,varargin)
    Iembryo=imtophat(1-I,strel('disk',20));
    res=(Iembryo-min(min(Iembryo)))/max(max((Iembryo-min(min(Iembryo)))));
end