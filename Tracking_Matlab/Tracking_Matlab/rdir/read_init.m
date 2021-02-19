function [end_reading,siz,fitsnom]=read_init(name,format,padding,first_frame,maxN,param_set,ignore_wrong_mask)
global new_run_ri;
% global name_;
% global rescue_path;

global session;

global STKplaneIndex;
global STKinfo;
global STKplaneInfo;
global Count;
global fin_ri;
% global mask;
global mask_BW;
global image_stack_global;

global param;
if nargin<5
    maxN = param.sp3;
end

% global thisListItem; % required by the system to avoid multiple init (commented right now)
% global docNode;
% global filexml;
% global inside_xml_job_read;

global tk1_im;
global tk2_im;

if ~isempty(param) && isfield(param,'channel_total') && ~isempty(param.channel_total) &&  param.channel_total>1
    first_frame=colored_index_to_file_index(first_frame,format);
% else
%     param.channel_total=1;
end

tk1_im=[];
tk2_im=[]; %required by read_with_trial_3D
NN=[]; % needed for saving the index


if (new_run_ri) %fitsread_modified use it!!
        name_=name;
end
end_reading=0;
            nom=sprintf('initialize image reading ...%s.%s',name,format);
            disp(nom);
          if (strcmp(format,'itif') || strcmp(format,'mtif') || strcmp(format,'fits')) && exist([name '.index.mat'],'file')
            load([name '.index.mat']);
            if strcmp(format,'stk')
                fin_ri=min(fin_ri,NN);
            else
                fin_ri=min(fin_ri,siz(length(siz)));
            end
            fitsnom=fitsnom_short;
            path_=fileparts(name); % to adapt to change of path (pc/mac etc)
            for iii_=1:length(fitsnom_short)
                fitsnom{iii_}=fullfile(path_,fitsnom_short{iii_}); % fitsnom_short contains already the potential rescue path
            end
            not_loaded=0;
            info_perso('Using short read_init');
            
          else
              not_loaded=1;
              name_=name;
          end

                    
%tmp%      if ~isfield(param,'end_reading') || ~isfield(param,'siz')  || ~isfield(param,'fitsnom') 
          switch (format)
%%              
              case {'omero_andor','omero_roper','omero_inscoper'}
                  if isempty(session)
                      disp('auto-init omero');
                      omero_init;
                  end
                  challengeOmeroConnection;
                  [fitsnom, siz,~,~,name,ext__] = read_init_omero_helper(name,format);                
                  fin_ri=min(fin_ri,siz(end));
              case {'image_stack'}
                  siz=size(image_stack_global,3);
                  fitsnom=[];
              case {'tif','ltif'}
                for i=first_frame:maxN  
                    switch padding
                        case 0
                            format='%s%d.tif';
                        case -1
                            format='%s.tif';
                        otherwise
                            format=sprintf('%%s%%0%dd.tif',padding);
                    end
                    if padding<0
                        nom=sprintf(format,name_);
                    else
                        nom=sprintf(format,name_,i);
                    end
                    if (exist(nom,'file'))
                        break;
                    end
                end
                siz(1)=i;
                siz(2)=maxN;
                if (~exist(nom,'file'))
                        if ~isempty(param.rescue_path)
                            nom0=nom;
                            [pathstr_, name_, ext_] = fileparts(name_);
                            name_=fullfile(pathstr_,param.rescue_path,sprintf('%s%s',name_,ext_));
                            nom=sprintf(format,name_,first_frame);
                            warning_perso('cannot find the image file %s\n\tSwitching to rescue path, try %s',nom0,nom);
                            % name_changed=1;
                            if (~exist(nom,'file'))
                                end_reading=1;
                                error('JACQ:FILENOTFOUND','cannot find the image file %s',nom);
                            else
                                end_reading=0;
                            end
                        else
                                end_reading=1;
                                error('JACQ:FILENOTFOUND','cannot find the image file %s',nom);
                        end

                else
                    end_reading=0;
                end
                  fitsnom{1}=name_;
%%                  
              case {'fits'}
                try
                   if not_loaded 
                        fitsnom{1}=sprintf('%s.fits',name_);
                        try
                            inf=fitsinfo(fitsnom{1});
                        catch error_
                           s=error_;
                           reporter(nan,error_,mfilename);
                           warning_perso('Catch error in read_init 1\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                            if ~isempty(param.rescue_path)
                                nom0=fitsnom{1};
                                [pathstr_, name_, ext_] = fileparts(name_);
                                name_=fullfile(pathstr_,param.rescue_path,sprintf('%s%s',name_,ext_));
                                 fitsnom{1}=sprintf('%s.fits',name_);
                                warning_perso('cannot find the image file %s\n\tSwitching to rescue path%s',nom0,fitsnom{1});
                                inf=fitsinfo(fitsnom{1});
                            else
                                rethrow(s);
                            end
                        end

                        si=inf.PrimaryData.Size;
                        siz(1)=inf.PrimaryData.Size(size(si,2));
                        ii=2;
                        end_reading2=0;
                        while ( (~end_reading2))
                            try
                                fitsnom{ii}=sprintf('%s._X%d.fits',name_,ii);
                                inf=fitsinfo(fitsnom{ii});
                                si=inf.PrimaryData.Size;
                                siz(ii)=siz(ii-1)+inf.PrimaryData.Size(size(si,2));
                                ii=ii+1;
                            catch error_
                               s=error_;
                               reporter(nan,error_,mfilename);
                               warning_perso('Catch error in read_init 2\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                               end_reading2=1;
                               fitsnom(ii)=[];
                               if (isempty(strfind(s.identifier,'MATLAB:fitsinfo:fileOpen')))
                                   rethrow(s);
                               end
                            end
                        end
                        fin_ri=min(fin_ri,siz(ii-1));
                   end % not_loaded
                catch error_
                    reporter(nan,error_,mfilename);
                    warning_perso('Catch error in read_init 3\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                    end_reading=1;
                    nom__=sprintf('failed : %s\n\terror # %s : %s\n%s\n',name,error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                    error('JACQ:READERROR','error reading the file (see report below) : %s\n%s',fitsnom{1},nom__);


                end
%%
              case {'mtif'}
                try
                   if not_loaded 
                        fitsnom{1}=sprintf('%s.tif',name_);
                        if ~exist(fitsnom{1},'file')
                            error('Cannot find %s. You are maybe analysing simulated data',fitsnom{1});
                        end
                        try
%                             inf=imfinfo(fitsnom{1});
                            try
                                inf=imfinfo(fitsnom{1});
                            catch error_
                               reporter(nan,error_,mfilename);
                               warning_perso('Catch error in read_init 5\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                               disp('TODO implement image info for 16bits tiff')
                               inf_=input('Number of frame in multi-image tif file (1 if not multiframe)');
                               inf=zeros(inf_,1);
                            end
                        catch error_
                           s=error_;
                           reporter(nan,error_,mfilename);
                           warning_perso('Catch error in read_init 6\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                            if ~isempty(param.rescue_path)
                                nom0=fitsnom{1};
                                [pathstr_, name_, ext_] = fileparts(name_);
                                name_=fullfile(pathstr_,param.rescue_path,sprintf('%s%s',name_,ext_));
                                % name_changed=1;
                                fitsnom{1}=sprintf('%s.tif',name_);
                                warning_perso('cannot find the image file %s\n\tSwitching to rescue path%s',nom0,fitsnom{1});
                                inf=fitsinfo(fitsnom{1});
                            else
                                rethrow(s);
                            end
                        end
                        disp(sprintf('File %s found',fitsnom{1}));
        %                 si=inf.PrimaryData.Size;
                        siz(1)=length(inf);
                        ii=2;
                        end_reading2=0;
                        while ((~end_reading2))
                            try
                                fitsnom{ii}=sprintf('%s_X%d.tif',name_,ii);
                                inf=imfinfo(fitsnom{ii});
                                disp(sprintf('File %s found',fitsnom{ii}));
        %                         si=inf.PrimaryData.Size;
                                siz(ii)=siz(ii-1)+length(inf);
                                ii=ii+1;
                            catch error_
                               s=error_;
                               reporter(nan,error_,mfilename);
                               warning_perso('Catch error in read_init 7\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                               end_reading2=1;
                               fitsnom(ii)=[];
                               if (isempty(strfind(s.identifier,'MATLAB:imagesci:imfinfo:fileOpen')))
                                   rethrow(s);
                               end
                            end
                        end
                        fin_ri=min(fin_ri,siz(ii-1));
                   end
                catch error_
                    reporter(nan,error_,mfilename);
                    warning_perso('Catch error in read_init 8\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                    end_reading=1;
                    nom__=sprintf('failed : %s\n\terror # %s : %s\n%s\n',name,error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                    error('JACQ:READERROR','error reading the file (see report below) : %s\n%s',fitsnom{1},nom__);


                end

%%
              case {'stk'}
                try
                    fitsnom{1}=sprintf('%s.stk',name_);
                    try
                        [STKplaneIndex,STKinfo,STKplaneInfo,Count,NN] = STK_info(fitsnom{1});
                        fin_ri=min(NN,fin_ri);
                    catch error_
                       reporter(nan,error_,mfilename);
                       s=error_;
                       warning_perso('Catch error in read_init 9\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                        if ~isempty(param.rescue_path)
                            nom0=fitsnom{1};
                            [pathstr_, name_, ext_] = fileparts(name_);
                            name_=fullfile(pathstr_,param.rescue_path,sprintf('%s%s',name_,ext_));
                            % name_changed=1;
                            fitsnom{1}=sprintf('%s.fits',name_);
                            warning_perso('cannot find the image file %s\n\tSwitching to rescue path%s',nom0,fitsnom{1});
                            [STKplaneIndex,STKinfo,STKplaneInfo,Count] = STKinfo(fitsnom{1});
                        else
                            rethrow(s);
                        end
                    end

                catch error_
                   reporter(nan,error_,mfilename);
                   warning_perso('Catch error in read_init 10\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                    end_reading=1;
                    nom__=sprintf('failed : %s\n\terror # %s : %s\n%s\n',name,error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                    error('JACQ:IMFILENOTFOUND','cannot find the image file %s\n%s',fitsnom{1},nom__);
                end
                siz=-1;
%%                
                case {'itif'}
                try
                    if not_loaded
                        if strcmp(name_((length(name_)-1):length(name_)),'_t')
                            fitsnom{1}=sprintf('%s0000.tif',name_);
                            try
                                inf=imfinfo(fitsnom{1});
                            catch error_
                               reporter(nan,error_,mfilename);
                               s=error_;
                               warning_perso('Catch error in read_init 11\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                                if ~isempty(param.rescue_path)
                                    nom0=fitsnom{1};
                                    [pathstr_, name_, ext_] = fileparts(name_);
                                    name_=fullfile(pathstr_,param.rescue_path,sprintf('%s%s',name_,ext_));
                                    % name_changed=1;
                                    fitsnom{1}=sprintf('%s0000.tif',name_);
                                    warning_perso('cannot find the image file %s\n\tSwitching to rescue path%s',nom0,fitsnom{1});
                                    inf=fitsinfo(fitsnom{1});
                                else
                                    rethrow(s);
                                end
                            end
                            disp(sprintf('File %s found',fitsnom{1}));
            %                 si=inf.PrimaryData.Size;
                            siz(1)=length(inf);
                            ii=2;
                            end_reading2=0;
                            while ((~end_reading2))
                                try
                                    fitsnom{ii}=sprintf('%s%04d.tif',name_,ii-1);
                                    inf=imfinfo(fitsnom{ii});
                                    disp(sprintf('File %s found',fitsnom{ii}));
            %                         si=inf.PrimaryData.Size;
                                    siz(ii)=siz(ii-1)+length(inf);
                                    ii=ii+1;
                                catch error_
                                   reporter(nan,error_,mfilename);
                                   s=error_;
                                   warning_perso('Catch error in read_init 12\n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                                   end_reading2=1;
                                   fitsnom(ii)=[];
                                   if (isempty(strfind(s.identifier,'MATLAB:imfinfo:fileOpen')))
                                       rethrow(s);
                                   end
                                end
                            end
                            fin_ri=min(fin_ri,siz(ii-1));
                        else %%%single chunk
                            fitsnom{1}=[name_ '.tif'];
                            inf=imfinfo(fitsnom{1});
                            siz(1)=length(inf);
                            end_reading2=0;
                        end
                    end
                catch error_
                    end_reading=1;
                    reporter(nan,error_,mfilename);
                    nom__=sprintf('failed : %s\n\terror # %s : %s\n%s\n',name,error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
                    error('JACQ:READERR','error reading the file (see report below) : %s\n%s',fitsnom{1},nom__);


                end

%%              
              otherwise
                  error('JACQ:FORMATNOTSUPPORT','format not supported');



          end % end of switch
          if (strcmp(format,'itif') || strcmp(format,'mtif') || strcmp(format,'fits')) && not_loaded
              if exist([name '.index.mat'],'file')
                  warning_perso('index.mat file was created in the meantime');
              else
                  fitsnom_short=fitsnom;
                  for iii_=1:length(fitsnom_short)
                      [dummy name__ ext__]=fileparts(fitsnom_short{iii_});
                      fitsnom_short{iii_}=[name__ ext__];
                  end
                save('-v7.3',[name '.index.mat'],'siz','fitsnom_short','fin_ri','NN');
              end
          end
          
          
          
          
%tmp%          if ( exist('inside_xml_job_read','var') && ~isempty(inside_xml_job_read) && inside_xml_job_read==1) 
%tmp%              param.end_reading=end_reading;
%tmp%              param.siz=siz;
%tmp%              param.fitsnom=fitsnom;

%tmp%              write_replace_entry(docNode,thisListItem,'end_reading',end_reading);
%tmp%              write_replace_entry(docNode,thisListItem,'siz',siz);
%tmp%              write_replace_entry(docNode,thisListItem,'fitsnom',fitsnom);

%tmp%              xmlwrite(filexml,docNode);
%tmp%          end
 %tmp%     else
%tmp%          end_reading=param.end_reading;
%tmp%          siz=param.siz';
%tmp%          fitsnom=param.fitsnom;
%tmp%      end % if isfield ...


    if nargin>=6 && ~isempty(param_set)
      if ~isempty(param) && isfield(param.(param_set),'mask_image') && ~isempty(param.(param_set).mask_image)
          if isempty(strfind(format,'omero'))
              mask_BW=logical(imread(param.(param_set).mask_image));
          else
              path = saveFirstFileAnnotationByNameFromDataset(name, param.(param_set).mask_image,tempdir_perso);
              mask_BW=logical(imread(path,'tif'));
              delete(path);
              rmdir(fileparts(path));
          end
      end
    elseif ~isempty(param) && isfield(param,'mask') && ~isempty(param.mask)
          if isempty(strfind(format,'omero'))
              mask_BW=logical(imread(param.mask));
          else
              path = saveFirstFileAnnotationByNameFromDataset(name, param.mask,tempdir_perso);
              mask_BW=logical(imread(path,'tif'));
              delete(path);
              rmdir(fileparts(path));
          end
    else
        mask_BW=[];
    end
    if  ~isempty(mask_BW) && all(all(mask_BW==0))
        if ~exist('ignore_wrong_mask','var') || isempty(ignore_wrong_mask) ...
                || ~ignore_wrong_mask
            error('The mask exclude all the pixels of the image! Something is wrong there.');
        else
            mask_BW=[];
        end
    end
      if isempty(strfind(format,'omero')) &&  ~isempty(param) && isfield(param,'channel_total') && ~isempty(param.channel_total) && param.channel_total>1
            fin_ri=fin_ri/param.channel_total;
      end
end
