function MakeQTMovie(cmd,arg, arg2)
     global param;
        if isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java
            return 
        end
    persistent myVideo;
    persistent myVideo_opened;
    persistent tiffName;
    persistent Width;
    persistent Height;
    switch lower(cmd)
        case {'start'}
            myVideo = VideoWriter(arg,'Motion JPEG AVI');
%              myVideo.FileFormat='avi';
            myVideo_opened=0;
            Width=[];
            Height=[];
        case {'framerate'}
            myVideo.FrameRate = arg;
        case {'quality'}
            myVideo.Quality = 100*arg;
        case {'tiffcopy'}
            tiffName=arg;
        case {'addimage'}
            img=imread(arg);
            writeVideo_helper(myVideo,img);
        case {'addmatrix'}
            writeVideo_helper(myVideo,arg);
        case {'addfigurejp2'}
             writeVideo_helper(myVideo,arg);
        case {'size'}
%             Width=arg(1);
%             Height=arg(2);
             % work around for the size issue in movie generation
        case {'finish'}
            if myVideo_opened
                close(myVideo);
                myVideo_opened=0;
            end
            myVideo=[];
            tiffName=[];
            Width=[];
            Height=[];
        case {'Cleanup'}
            % nop

    end
    function writeVideo_helper(arg1,arg2)
        if ~myVideo_opened
            open(myVideo);
            myVideo_opened=1;
        end
        if ishandle(arg2)
            if ~isempty(Width) && ~isempty(Height)
                set_fig_size(arg2,Width,Height);
            end
            drawnow_perso;
            arg2_=getframe(arg2);
%             if ~isempty(Width) && ~isempty(Height) && (size(rgb,1)~=Height || size(rgb,2)~=Width)
%                 warning_perso('Need to re-get frame because size was altered');
%                 set_fig_size(arg2,Width,Height);
%                 rgb=print(arg2,'-RGBImage','-r0');
%             end
            writeVideo(arg1,arg2_);
        end
        if ~isempty(tiffName)
            rgb=print(arg2,'-RGBImage','-r0');
            imwrite(uint8(rgb),tiffName,'tif','WriteMode','append');
        end
        if isempty(Width) || isempty(Height)
            set(arg2,'Unit','pixel');
            pos_=get(arg2,'Position');
        end
        if isempty(Width)
            Width=pos_(3);
        end
        if isempty(Height)
            Height=pos_(4);
        end
    end
    function [pos_,unit_]=set_fig_size(arg2,Width,Height)
                if nargout>=1
                    pos_=get(arg2,'Position');
                end
                if nargout>=2
                    unit_=get(arg2,'Unit');
                end
                set(arg2,'Unit','pixel');
                set(arg2,'Position',[1 1 Width Height]);
                if any(get(arg2,'Position')~=[1 1 Width Height])
                    warning('Failed to resize the fig');
                end
    end
end
