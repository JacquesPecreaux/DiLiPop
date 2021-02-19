function [ Image ] = Imagee_processor( Image,param_set,adjust_image,filter_image,imtophat_image,clahe_image )

global param

    if (adjust_image)
        Image=imadjust(Image);
    end 

%     Image_backup = Image; % used for optimization

    if filter_image
        switch param.(param_set).kind_filter
            case 'gaussian'
                h_gaussian = fspecial('gaussian',[3 3],5);
                Image = imfilter(Image,h_gaussian);
            case 'average'
                h_average = fspecial('average',[3 3]);
                Image = imfilter(Image,h_average);
            case 'disk'
                h_disk = fspecial('disk',5);
                Image = imfilter(Image,h_disk);
            case 'laplacian'
                h_laplacian = fspecial('laplacian',0.2);
                Image = imfilter(Image,h_laplacian);
            case 'log'
                h_log = fspecial('log',[5 5],0.5);
                Image = imfilter(Image,h_log);
            case 'prewitt'
                h_prewitt = fspecial('prewitt');
                Image = imfilter(Image,h_prewitt);
            case 'sobel'
                h_sobel = fspecial('sobel');
                Image = imfilter(Image,h_sobel);
        end
    end

    if (imtophat_image)
        Image = mask_and_imtophat(Image,param_set);
    end

    if (clahe_image)
        Image = perform_clahe(Image,param_set);
    end
            
end
            
            