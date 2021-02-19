function [fitsnom, siz,sizeC,sizeZ,name,ext__] = read_init_omero_helper(name,format)
    global session;
      [~,name,ext__] = fileparts(name);
      datasets=getDatasets(session,str2double(name),true);
      imageList = datasets(1).linkedImageList;
      if imageList.size()==0
          error('I cannot find images in this dataset');
      end
      imageNames = cell(imageList.size(),1);
      for j = 0:imageList.size()-1
        imageNames{j+1} = char(imageList.get(j).getName().getValue());
      end
      imageNames = sortNumberedWithoutPadding(imageNames,format);
      fitsnom=int32(zeros(length(imageNames),1));
      siz=zeros(1,length(fitsnom));
      for j=1:length(fitsnom)
          imageList = getImageFromDatasetByName(name,imageNames{j});
          if imageList.isEmpty
              error('I found no image in the dataset specified (DID=%s). Either it is erroneous or you logged in with the wrong group',name);
          end
          fitsnom(j)=imageList.get(0).getId().getValue();
          omeroImage = getImages(session, fitsnom(j));
          pixels = omeroImage.getPrimaryPixels();
          gotSizeZ=pixels.getSizeZ().getValue();
          gotSizeT=pixels.getSizeT().getValue();
          gotSizeC=pixels.getSizeC().getValue();
          if endsWith(imageNames{j},'.fits') && gotSizeT==1 && gotSizeZ>1
              tmp=gotSizeT;
              gotSizeT=gotSizeZ;
              gotSizeZ=tmp;
              warning_perso('Apply the workaround on fits assuming buggy andor fits with time encoded as Z dimension');
          end
          if j==1
              sizeC = gotSizeC;
              sizeZ = gotSizeZ;
          else
              if sizeC ~= gotSizeC || sizeZ ~= gotSizeZ
                  error('Inconsistent data set: some file chunks have different number of Z planes or channels');
              end
          end
          siz(j)= gotSizeT * sizeZ; % color is handled in a different fashion
          if j>1
              siz(j) = siz(j) + siz(j-1);
          end
      end                 
end