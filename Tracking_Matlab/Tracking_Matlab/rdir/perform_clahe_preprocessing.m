function [ CEImage ] = perform_clahe_preprocessing( Image,Cliplimit )


%    Image - The input/output image
%    XRes - Image resolution in the X direction
%    YRes - Image resolution in the Y direction
%    Min - Minimum greyvalue of input image (also becomes minimum of output image)
%    Max - Maximum greyvalue of input image (also becomes maximum of output image)
%    NrX - Number of contextial regions in the X direction (min 2, max uiMAX_REG_X)
%    NrY - Number of contextial regions in the Y direction (min 2, max uiMAX_REG_Y)
%    NrBins - Number of greybins for histogram ("dynamic range")
%    Cliplimit - Normalized cliplimit (higher values give more contrast)

    Image = im2uint8(Image);

    Min = 0;
    Max = 255;
    NrX = 6;  % 12
    NrY = 6;  %12
    NrBins = 256;
  %  Cliplimit = 3; %default = 1.5


	[ Image,dimI,noPadRect] = pad_clahe( Image,NrX,NrY );
	
	XRes = dimI(1);
    YRes = dimI(2);
    
    [CEImage] = run_clahe(Image,XRes,YRes,Min,Max,NrX,NrY,NrBins,Cliplimit);
    
    if ~isempty(noPadRect) %do we need to remove padding?
        CEImage = CEImage(noPadRect.ulRow:noPadRect.lrRow, ...
        noPadRect.ulCol:noPadRect.lrCol);
    end
    
    CEImage = mat2gray(CEImage);
    
end

