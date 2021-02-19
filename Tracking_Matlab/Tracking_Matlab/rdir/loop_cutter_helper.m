function [Cxm,Cym]=loop_cutter_helper(loop_begin,loop_end,Cxm,Cym,Psize)
       if loop_begin>loop_end
           first_p=loop_end;
           last_p=loop_begin;
           number_point_low=first_p-1;
           number_point_high=Psize-last_p;
           number_point=number_point_low+number_point_high+1; % there is an interval between last point and first point
           Cxm((last_p+1):Psize)=Cxm(last_p)+(1:number_point_high)/number_point*...
               (Cxm(first_p)-Cxm(last_p));
           Cym((last_p+1):Psize)=Cym(last_p)+(1:number_point_high)/number_point*...
               (Cym(first_p)-Cym(last_p));
           Cxm((1):(first_p-1))=Cxm(last_p)+((number_point_high+1):(number_point-1))/number_point*...
               (Cxm(first_p)-Cxm(last_p));
           Cym((1):(first_p-1))=Cym(last_p)+((number_point_high+1):(number_point-1))/number_point*...
               (Cym(first_p)-Cym(last_p));
       else
           last_p=loop_end;
           first_p=loop_begin;
           number_point=last_p-first_p;
           Cxm((first_p+1):(last_p-1))=Cxm(first_p)+(1:(number_point-1))/number_point*...
               (Cxm(last_p)-Cxm(first_p));
           Cym((first_p+1):(last_p-1))=Cym(first_p)+(1:(number_point-1))/number_point*...
               (Cym(last_p)-Cym(first_p));
       end
end