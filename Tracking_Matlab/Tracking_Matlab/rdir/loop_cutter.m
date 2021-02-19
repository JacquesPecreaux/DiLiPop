function [Cxm,Cym]=loop_cutter(loop_begin,loop_end,t,Cxm,Cym,shift,Psize)
    [Cxm((shift+1):(Psize+shift),t+1),Cym((shift+1):(Psize+shift),t+1)]=...
        loop_cutter_helper(loop_begin-shift,loop_end-shift,Cxm((shift+1):(Psize+shift),t+1),Cym((shift+1):(Psize+shift),t+1),Psize);

%        if loop_begin>loop_end
%            first_p=loop_end;
%            last_p=loop_begin;
%            number_point_low=first_p-(shift+1);
%            number_point_high=(Psize+shift)-last_p;
%            number_point=number_point_low+number_point_high+1; % there is an interval between last point and first point
%            Cxm((last_p+1):(Psize+shift),t+1)=Cxm(last_p,t+1)+(1:number_point_high)/number_point*...
%                (Cxm(first_p,t+1)-Cxm(last_p,t+1));
%            Cym((last_p+1):(Psize+shift),t+1)=Cym(last_p,t+1)+(1:number_point_high)/number_point*...
%                (Cym(first_p,t+1)-Cym(last_p,t+1));
%            Cxm((shift+1):(first_p-1),t+1)=Cxm(last_p,t+1)+((number_point_high+1):(number_point-1))/number_point*...
%                (Cxm(first_p,t+1)-Cxm(last_p,t+1));
%            Cym((shift+1):(first_p-1),t+1)=Cym(last_p,t+1)+((number_point_high+1):(number_point-1))/number_point*...
%                (Cym(first_p,t+1)-Cym(last_p,t+1));
%        else
%            last_p=loop_end;
%            first_p=loop_begin;
%            number_point=last_p-first_p;
%            Cxm((first_p+1):(last_p-1),t+1)=Cxm(first_p,t+1)+(1:(number_point-1))/number_point*...
%                (Cxm(last_p,t+1)-Cxm(first_p,t+1));
%            Cym((first_p+1):(last_p-1),t+1)=Cym(first_p,t+1)+(1:(number_point-1))/number_point*...
%                (Cym(last_p,t+1)-Cym(first_p,t+1));
%        end
end