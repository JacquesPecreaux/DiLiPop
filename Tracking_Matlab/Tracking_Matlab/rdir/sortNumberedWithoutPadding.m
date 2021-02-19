function imageNamesSorted = sortNumberedWithoutPadding(imageNames,format)
    if length(imageNames)==1
        imageNamesSorted=imageNames;
        return
    end
    sorterHelper = zeros(length(imageNames),2);
    sorterHelper(:,1)=(1:length(imageNames))';
    if length(imageNames)<1
        error('no image found');
    end
    switch format
        case {'omero_andor'}
            %                           stemLength=stemLength+2-4;
            idxXbar=regexp(imageNames,'_X[0-9]+\.\w*');
            idxFirst= find(cellfun(@isempty,idxXbar));
            if length(idxFirst)>1
                error('I found more than one Image without _X in this dataset');
            end
            sorterHelper(idxFirst,2)=1;
            sorterHelper(1:end~=idxFirst,2)=cellfun(@(imageName,begin) str2double(imageName(begin+2:((begin+2)+regexp(imageName((begin+2):end),'\.\w*')-2))),...
                imageNames(1:end~=idxFirst),idxXbar(1:end~=idxFirst));
            if any(cell2mat(idxXbar)~=(length(imageNames{idxFirst})+1-4))
                warning_perso('Images seem named with different stem - Are you sure they are not mixed up ?');
            end
        case {'omero_roper'}
            stemLength=length(imageNames{1});
            for ij=1:length(imageNames)
                stemLength=min(stemLength,length(imageNames{ij}));
            end
            stemLength=stemLength+5-4;
            for ij=1:length(imageNames)
                if length(imageNames{ij})<=(stemLength+4)
                    sorterHelper(ij,2)=1;
                else
                    sorterHelper(ij,2)=int32(str2double(imageNames{ij}((stemLength+1):(end-4))));
                end
            end
        case {'omero_inscoper'}
            common_to_use = imageNames{1}(all(~diff(char(imageNames(:)))));
            for ij=1:length(imageNames)
                imageNames_selection = imageNames{ij};
                imageNames_selection_ = imageNames_selection(length(common_to_use)+1:length(imageNames_selection)-5);
                if isempty(imageNames_selection_)
                    sorterHelper(ij,2) = 1;
                else
                    imageNames_selection__ = imageNames_selection_(2:length(imageNames_selection_));
                    sorterHelper(ij,2) = str2num(imageNames_selection__) + 1;
                end
            end        
    end
    sorterHelper = sortrows(sorterHelper,2);
    imageNamesSorted = cell(size(imageNames));
    for ij=1:length(imageNames)
        imageNamesSorted{ij} = imageNames{sorterHelper(ij,1)};
    end
end