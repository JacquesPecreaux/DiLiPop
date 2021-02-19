function [I,end_reading,error_reading,i,testEmpty]=read_with_trial(i,padding,format_image,siz,fitsnom,rect_type,n,varargin)
        global param;
            essai=1;
            end_reading=0;
            read_ok=0;
            max_trial=param.max_trial;
            if i<1
                error('Cannot read an image before the stack starts');
            end
    while ((i<=n) && ~end_reading && ~read_ok && max_trial>0)
        [I,end_reading,error_reading,testEmpty]=read_image(i,padding,format_image,siz,fitsnom,rect_type,varargin{:});
        if ~error_reading
                essai=1;
                read_ok=1;
        else
            max_trial=max_trial-1;
                if (~end_reading)
                    s=lasterror;
                    if (essai<param.trial_max)
                        disp(s.message);
                        disp(sprintf('retry to open frame # %d (tif_track) - trial # %d',i,essai));
                        essai=essai+1;
                        if param.trial_delay~=0
                            pause(param.trial_delay);
                        end
                    else
                        disp(s.message);
                        disp(sprintf('too many faillure, image # %d skipped (tif_track)',i));
                        essai=1;
                        i=i+1;
                    end
                end
        end
        
    end
    if ~read_ok
        I=[];
        end_reading=1;
        error_reading=1;
    end
        
end