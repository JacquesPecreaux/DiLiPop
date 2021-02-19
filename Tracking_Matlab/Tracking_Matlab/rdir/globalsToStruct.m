function res = globalsToStruct
       s=whos('global');
       for ik_=1:length(s)
            eval(['global ' s(ik_).name]);
            res.(s(ik_).name)=eval(s(ik_).name);
       end
end