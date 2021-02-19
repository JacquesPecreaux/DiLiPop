    function [II,tmp]=get_II_tmp(I)
        global param;
        global level;
         if ~isempty(param) && isfield(param,'orga_model') && ~isempty(param.orga_model)  && strcmp(param.orga_model,'pombe')
            II=imfilter(I,fspecial('disk',2)); % for background level computation
            tmp=II;
         else
            II=imfilter(I,fspecial('disk',2)); 
             level=graythresh(II);
             if level==0
                 warning_perso('Failed to threshold the image with Otsu''s method in read_image - I will consider the whole image as a work-around rather than the non object pixels');
                 tmp=II;
             else
                tmp=II(II<=level);
             end
         end
    end
