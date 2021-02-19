function [ref_im_tmp]=get_model(res_)
    p = mfilename('fullpath');
    pathstr = fileparts(p);
    ref_im_path=fullfile(pathstr,'modelCS.tif');
    ref_im_tmp=imresize(im2double(imread(ref_im_path)),160/res_,'bicubic');
    if (min(min(ref_im_tmp,[],1),[],2)<0)
        ref_im_tmp=ref_im_tmp-min(min(ref_im_tmp,[],1),[],2);
        warning_perso('resizing modelCS gave negative values : rescaling!');
    end
    if (max(max(ref_im_tmp,[],1),[],2)>1)
        ref_im_tmp=ref_im_tmp./max(max(ref_im_tmp,[],1),[],2);
        warning_perso('resizing modelCS gave values larger than max grey level : rescaling!');
    end
end