function [I,end_reading,error_reading,isNotEmpty]=read_image(i,padding,format,siz,fitsnom,cropping,channel_interest_,mask_)
    global new_run_ri;
%     global max_level;
%     global name_; 
    global STKplaneIndex;
    global STKinfo;
    global STKplaneInfo;
    global Count;
%     global mask;
%     global level;
    global image_stack_global;
    global param;
    global general_param
    global session;
    global omero_use_original;
    
%     persistent pixelsList;
    global pixels; % need to clear it when closing omero
    global store;
    persistent imageID;
    persistent current_session;
    
    if nargin<7 || isempty(channel_interest_)
        channel_interest_=param.channel_interest;
    end
    if nargin<8 || isempty(mask_)
        mask_=param.mask;
    end
    if param.channel_total>1
        i=colored_index_to_file_index(i,format);
    end
    
    function [I]=im2double_special(I)
            rml=double(max(max(I,[],1),[],2));
            if (rml>param.max_level)
                param.max_level=param.max_level*2^ceil(log(rml/param.max_level)/log(2));
                warning_perso('max_level modified to match the image');
            end
            if isa(I,'float')
                if max(max(I))>256
                    if max(max(I))>65536
                        warning_perso('Resceling by maximum - float data seems not coming from 8 or 16 bits (integer) data');
                        I=I/max(max(I));
                    else
                        I=I/65536;
                    end
                else
                    I=I/256;
                end
                I=double(I);
            else
                I=im2double(I);
            end
            if (param.max_level>256)
                 I=I*(65536/param.max_level);
            else
                I=I*(256/param.max_level);
            end
    end
%     if (new_run_ri)
%         p = mfilename('fullpath');
%         Version_perso(p);
        % new_run_ri=0 at the end because fits_read... need it
%     end
    I=[];
    end_reading=0;
    error_reading=0;
    isNotEmpty=[];
    switch (format)
          case {'omero_andor','omero_roper','omero_inscoper'}
              try
                  ind=1;
                  while ((size(siz,2)>=ind) && (siz(ind)<i))
                      ind=ind+1;
                  end
                  if (size(siz,2)>=ind)
                     if (ind>1)
                        ii=i-siz(ind-1);
                     else
                        ii=i;
                     end
                     %%
                     challengeOmeroConnection;
                    if isempty(imageID) || ( imageID ~= fitsnom(ind)) || isempty(pixels) || isempty(current_session) || (current_session~=session)
                        imageID = fitsnom(ind);
                        current_session=session;
                        if isa(store,'omero.api.RawPixelsStorePrxHelper')
                            store.close()
                        end
                        [store, pixels] = getRawPixelsStore(session, imageID);
                    end
                    if ~exist('omero_use_original','var') || isempty(omero_use_original) || ~omero_use_original
                        get_from_orig = 0;
                        try
                            if  pixels.getSizeT().getValue()>1
                                zIdx = rem(ii-1,param.z_planes_nb);
                                timeIdx = fix((ii-1)/param.z_planes_nb);
                                I=getPlane(pixels, store,zIdx,channel_interest_-1,timeIdx);
                                I = permute(I,[2 1 3:ndims(I)]);
                                
                                % possibility to perform binning, after imaging, here sum pixel intensity to the
                                % next X (param.decimate-1) images
                                
                                if ~isfield(general_param.cortex_analysis,'sum_intensity_binning')
                                    general_param.cortex_analysis.sum_intensity_binning = 0;
                                end
                                
                                if general_param.cortex_analysis.sum_intensity_binning == 1 && (ii+param.decimate) <= param.sp3
                                    
                                    for index_decimate = 1 : (param.decimate-1)
                                        ii_ = ii + index_decimate;
                                        zIdx = rem(ii_-1,param.z_planes_nb);
                                        timeIdx = fix((ii_-1)/param.z_planes_nb);
                                        I_decimate = getPlane(pixels, store,zIdx,channel_interest_-1,timeIdx);
                                        I_decimate = permute(I_decimate,[2 1 3:ndims(I)]);
                                        I = I + I_decimate;
                                    end                                                        
                                    
                                end
                                
                            elseif param.z_planes_nb==1
                                I=getPlane(pixels, store,ii-1,channel_interest_-1,0);
                            else
                                error('Channel / Z-planes / timepoints organization of stack not handled');
                            end
                        catch error_
                            reporter(nan,error_,mfilename);
                            warning_perso(['Back to original file - exception for information' newline ...
                            ' ======================= Begining of cathed exception ==================' newline ...
                            error_.message newline ...
                            ' ======================= End of cathed exception ==================' newline ]);
                            get_from_orig = 1;
                        end
                    else
                        if param.channel_total>1
                            error('use of original image with more than one channel not implemented');
                        end
                        get_from_orig = 1;
                    end
                    if get_from_orig
                        I= get_from_original_file_from_Pixels(pixels.getId().getValue(),ii);
                    end
                    % BEWARE: indexing above starts at 0
                    % TODO handle case where time z-slice is not changing
                    % but something else.
                    fprintf('omero.andor image id %d read at index %d !\n',fitsnom(ind),ii);
                    %%
                    if ~isempty(param) && isfield(param,'phys_cut') && ~isempty(param.phys_cut)  && param.phys_cut
                        hgauss = fspecial('gaussian',[15 15],5);
                        I = imfilter(I,hgauss);
                        I= perform_clahe_preprocessing( I,1.5 );
                    end
%                     if ~isempty(param) && isfield(param,'toulouse') && ~isempty(param.toulouse)  && param.toulouse
%                         I= perform_clahe_preprocessing( I,1.5 );
%                     end
                  I=im2double_special(I);  
                  else
                      end_reading=1;
                      error('JACQ:OMEROIDXOUTOFRANGE','required index for fits set of file out of range');
                  end
                catch error_
                    reporter(nan,error_,mfilename);
                   warning_perso('Catch error in read_image 2\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,newline,sprintf('\n\t')),stack_text(error_.stack));
                  error_reading=1;
              end

          case {'image_stack'}
              try
                if i<=size(image_stack_global,3)
                    I=image_stack_global(:,:,i);
                    I=im2double_special(I);
                else
                    warning_perso('Request an slice beyong the size of the stack in format "image_stack"');
                    end_reading=1;
                    error_reading=1;
                end
                info_perso(['read image stack at slice ' num2str(i,'%d')]);
                catch error_
                   reporter(nan,error_,mfilename);
                   s=error_;
                   warning_perso('Catch error in read_image 1\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,newline,sprintf('\n\t')),stack_text(error_.stack));
                   error_reading=1;
                   if (isempty(strfind(s.message,'Error using ==> imread')))
                        end_reading=1;
                   else
                       rethrow(s);
                   end
              end
          case {'tif', 'ltif'}
            fprintf('image %d in progress...\n',i);
                switch padding
                    case 0
                        format='%s%d.tif';
                    case -1
                        format='%s.tif';
                    otherwise
                        format=sprintf('%%s%%0%dd.tif',padding);
                end
                if padding<0
                    nom=sprintf(format,fitsnom{1});
                else
                    nom=sprintf(format,fitsnom{1},siz(1)+(i-1));
                end
%             files=dir(nom);
%             if (size(files,1)==0)
%                         [pathstr_, name_, ext_, versn_] = fileparts(name_);
%                         name_=fullfile(pathstr_,'RawData',sprintf('%s%s',name_,ext_));
%                         nom=sprintf(format,name_,i);
%                         files=dir(nom);
%                         if (size(files,1)==0)
%                             end_reading=1;
%                         else
%                             end_reading=0;
%                         end
%             else
%                 end_reading=0;
%             end
            if (~end_reading)
                try
                    I=imread(nom);
                    fprintf('tif image %s read!\n',nom);
                    I=im2double_special(I);
                catch error_
                   reporter(nan,error_,mfilename);
                   s=error_;
                   warning_perso('Catch error in read_image 1\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,newline,sprintf('\n\t')),stack_text(error_.stack));
                   error_reading=1;
                   if (isempty(strfind(s.message,'Error using ==> imread')))
                        end_reading=1;
                   else
                       rethrow(s);
                   end
                end
            end
         
          case {'fits'}
              try
                  ind=1;
                  while ((size(siz,2)>=ind) && (siz(ind)<i))
                      ind=ind+1;
                  end
                  if (size(siz,2)>=ind)
                     if (ind>1)
                        ii=i-siz(ind-1);
                    else
                        ii=i;
                    end
                    I=fitsread_modified(fitsnom{ind},'primary',ii);
                    fprintf('fits image %s read at index %d !\n',fitsnom{ind},ii);
                    I=im2double_special(I);
                  else
                      end_reading=1;
                      error('JACQ:FITSIDXOUTOFRANGE','required index for fits set of file out of range');
                  end
                catch error_
                   reporter(nan,error_,mfilename);
                   warning_perso('Catch error in read_image 2\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,newline,sprintf('\n\t')),stack_text(error_.stack));
                  error_reading=1;
              end

          case {'mtif'}
              try
                  ind=1;
                  while ((size(siz,2)>=ind) && (siz(ind)<i))
                      ind=ind+1;
                  end
                  if (size(siz,2)>=ind)
                     if (ind>1)
                        ii=i-siz(ind-1);
                    else
                        ii=i;
                    end
                    I=imread(fitsnom{ind},'tif',ii);
                    fprintf('mtif image %s read at index %d !\n',fitsnom{ind},ii);
                    I=im2double_special(I);
                  else
                      end_reading=1;
                      error('JACQ:MTIFIDXOUTOFRANGE','required index for mtif set of file out of range');
                  end
                catch error_
                   reporter(nan,error_,mfilename);
                   warning_perso('Catch error in read_image 3\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,newline,sprintf('\n\t')),stack_text(error_.stack));
                  error_reading=1;
              end



        case {'stk'}
            try
                if (~end_reading)
                        I=STKread_image(fitsnom{1},i,STKplaneIndex,STKinfo,STKplaneInfo,Count);
                        fprintf('stk image # %d from  %s read!\n',i,fitsnom{1});
                        I=im2double_special(I);
                end
                catch error_
                  reporter(nan,error_,mfilename);
                  warning_perso('Catch error in read_image 4\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,newline,sprintf('\n\t')),stack_text(error_.stack));
                  error_reading=1;
            end

          case {'itif'}
              try
                  ind=1;
                  while ((size(siz,2)>=ind) && (siz(ind)<i))
                      ind=ind+1;
                  end
                  if (size(siz,2)>=ind)
                     if (ind>1)
                        ii=i-siz(ind-1);
                    else
                        ii=i;
                    end
                    I=imread(fitsnom{ind},'tif',ii);
                    fprintf('fits image %s read at index %d !\n',fitsnom{ind},ii);
                    I=im2double_special(I);
                  else
                      end_reading=1;
                      error('JACQ:ITIFIDXOUTOFRANGE','required index for itif set of file out of range');
                  end
                catch error_
                   reporter(nan,error_,mfilename);
                   warning_perso('Catch error in read_image 5\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,newline,sprintf('\n\t')),stack_text(error_.stack));
                  error_reading=1;
              end
            
            
        otherwise
            error('I fail to recognize format %s',format);
    end
%%
if error_reading
    return
end
%% 
    [II,tmp]=get_II_tmp(I);

    if isempty(tmp)
        switch (format)
            case { 'tif' }
                warning_perso('Image with only background %s !',nom);
            case { 'fits'}
                if (ind<=length(fitsnom))
                    warning_perso('Image with only background (or fits format error) %s at index %d !',fitsnom{ind},ii);
                else
                    if exist('ii','var') && ~isempty(ii)
                        warning_perso('Image with only background (or fits format error) at index %d !\n ind > length(fitsnom) ! call : read_image(%d,%d,%s,siz,fitsnom,%s)',ii,i,padding,format,cropping);
                    else
                        warning_perso('Image with only background (or fits format error) at index undefined (ii not existing or empty) !\n ind > length(fitsnom) ! call : read_image(%d,%d,%s,siz,fitsnom,%s)',i,padding,format,cropping);
                    end
                end
            case { 'stk'}
                warning_perso('Image with only background # %d from  %s !',i,fitsnom{1});
        end
    end
    if (param.check_image_before)
          %second try...better but still the slowest thing!
%                     filt_siz=round((r1/resolution)/4);
%                     filt=padarray(ones(filt_siz,filt_siz)/filt_siz^2,size(cIdn)-[filt_siz filt_siz],0,'post');
%                     cor=ifft2(fft2(cIdn).*fft2(filt)); % symetric filter so cobvolution and correlation equivalent.
%                     index=max(max(cor,[],1),[],2)/mean2(cIdn);
%                     test=(index>=1.0035);
          index=entropy(I);
          isNotEmpty=index>param.filtering_threshold;
          if ~isNotEmpty
              warning_perso('Found an empty image');
          end
          % 0.2760 on an empty frame
    else
        isNotEmpty=1;
    end

    
    [I, error_reading_] = cropping_helper(I,II,tmp,cropping,mask_);
    error_reading = error_reading || error_reading_;
        
    if (new_run_ri) %fitsread_modified use it!!
        new_run_ri=0;
    end

    

end