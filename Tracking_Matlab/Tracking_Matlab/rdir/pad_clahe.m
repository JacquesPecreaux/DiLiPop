function [ I,dimI,noPadRect] = pad_clahe( I,NrX,NrY )

%check if the image needs to be padded; pad if necessary;
%padding occurs if any dimension of a single tile is an odd number
%and/or when image dimensions are not divisible by the selected 
%number of tiles

	numTiles = [NrX NrY];
    dimI = size(I);
    dimTile = dimI ./ numTiles;

    rowDiv  = mod(dimI(1),numTiles(1)) == 0;
    colDiv  = mod(dimI(2),numTiles(2)) == 0;

    if rowDiv && colDiv
        rowEven = mod(dimTile(1),2) == 0;
        colEven = mod(dimTile(2),2) == 0;  
    end

    noPadRect = [];
    if  ~(rowDiv && colDiv && rowEven && colEven)
        padRow = 0;
        padCol = 0;
  
        if ~rowDiv
            rowTileDim = floor(dimI(1)/numTiles(1)) + 1;
            padRow = rowTileDim*numTiles(1) - dimI(1);
        else
            rowTileDim = dimI(1)/numTiles(1);
        end
  
        if ~colDiv
            colTileDim = floor(dimI(2)/numTiles(2)) + 1;
            padCol = colTileDim*numTiles(2) - dimI(2);
        else
            colTileDim = dimI(2)/numTiles(2);
        end
  
        %check if tile dimensions are even numbers
        rowEven = mod(rowTileDim,2) == 0;
        colEven = mod(colTileDim,2) == 0;
  
        if ~rowEven
            padRow = padRow+numTiles(1);
        end

        if ~colEven
            padCol = padCol+numTiles(2);
        end
  
        padRowPre  = floor(padRow/2);
        padRowPost = ceil(padRow/2);
        padColPre  = floor(padCol/2);
        padColPost = ceil(padCol/2);
  
        I = padarray(I,[padRowPre  padColPre ],'symmetric','pre');
        I = padarray(I,[padRowPost padColPost],'symmetric','post');

        %UL corner (Row, Col), LR corner (Row, Col)
        noPadRect.ulRow = padRowPre+1;
        noPadRect.ulCol = padColPre+1;
        noPadRect.lrRow = padRowPre+dimI(1);
        noPadRect.lrCol = padColPre+dimI(2);
    end

    %redefine this variable to include the padding
    dimI = size(I);

    %size of the single tile
    dimTile = dimI ./ numTiles;
    
    %%



    

end

