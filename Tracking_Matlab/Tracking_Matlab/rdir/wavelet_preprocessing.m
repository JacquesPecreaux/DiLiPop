function I_=wavelet_preprocessing(I,varargin)
    [cA,cH,cV,cD] = dwt2(imadjust(I),'haar');
    cA=cA*0;
    cD=cD*0;
    I_=idwt2(cA,cH,cV,cD,'haar');
end
