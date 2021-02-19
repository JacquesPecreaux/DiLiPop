% macro resample_AC
global param;
global Image_param;
if ~exist('tt','var')
    tt=0;
end
if ~exist('resample_each','var')
    resample_each=0;
end

if param.(param_set).AC_method>=1000
    if ((mod(tt,resample_each)==0) || force_resample ) && tt~=2
                    force_resample=0;
        if param.(param_set).reinit_iterations>0
            disp('resetting signed function');
            if param.(param_set).medfilt_when_resampling
                Level_set_fct=medfilt2(Level_set_fct); % remove salt and peper noise from derivatives
            end
            Level_set_fct=Image_param.reinit_lsf(Level_set_fct,param.(param_set).LS_dx,param.(param_set).LS_dy, param.(param_set).LS_alpha,param.(param_set).LS_algo_diff_resamp, param.(param_set).reinit_iterations);
        end

    end
else
    if ((mod(tt,resample_each)==0) || force_resample ) && tt~=2
        force_resample=0;

        %%%equally spaced
        dxa=diff(Cxm(:,t+1)); dya=diff(Cym(:,t+1));
        length_=sqrt(dxa.^2+dya.^2);
        % cutting little loops if there are some
        [x0,y0,segments]=selfintersect(Cxm((1+shift):(Psize+shift),t+1),Cym((1+shift):(Psize+shift),t+1));
        if ~isempty(x0)
           for ik_=1:size(segments,1)
               if segments(ik_,1)>segments(ik_,2)
                   first_p=segments(ik_,2)+shift;
                   last_p=segments(ik_,1)+shift;
               else
                   first_p=segments(ik_,1)+shift;
                   last_p=segments(ik_,2)+shift;
               end
               l_in=sum(length_(first_p:(last_p-1)));
               l_out=sum(length_((shift+1):(first_p-1)))+sum(length_(last_p:(Psize+shift)));
               if l_in>l_out
                   [Cxm,Cym]=loop_cutter(last_p,first_p,t,Cxm,Cym,shift,Psize);
               else
                   [Cxm,Cym]=loop_cutter(first_p,last_p,t,Cxm,Cym,shift,Psize);
               end
           end
            %%cyclic boundaries
            Cxm(1:shift,t+1)=Cxm((Psize+1):(Psize+shift),t+1); Cym(1:shift,t+1)=Cym((Psize+1):(Psize+shift),t+1);
            Cxm((Psize+shift+1):(Psize+2*shift),t+1)=Cxm((shift+1):(2*shift),t+1); Cym((Psize+shift+1):(Psize+2*shift),t+1)=Cym((shift+1):(2*shift),t+1);

            dxa=diff(Cxm(:,t+1)); dya=diff(Cym(:,t+1));
            length_=sqrt(dxa.^2+dya.^2);
        end

        % resampling

        [Cxm((shift+1):(Psize+shift),t+1),Cym((shift+1):(Psize+shift),t+1),dl0m((shift+1):(Psize+shift))]=...
            equal_spacer(length_((shift+1):(Psize+shift)),Psize,Cxm((shift+1):(Psize+shift),t+1),Cym((shift+1):(Psize+shift),t+1),dl0m((shift+1):(Psize+shift)),param_set);


          [Cxm(:,t+1),Cym(:,t+1),dl0m]=boundary_conditions(Cxm(:,t+1),Cym(:,t+1),Psize,shift,dl0m,param_set);
    else
        [Cxm(:,t+1),Cym(:,t+1)]=boundary_conditions(Cxm(:,t+1),Cym(:,t+1),Psize,shift,[],param_set);
    end            
end