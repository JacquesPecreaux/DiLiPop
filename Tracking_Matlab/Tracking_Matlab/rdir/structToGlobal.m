function structToGlobal(res)
    fields = fieldnames(res);
    for ik_=1:length(fields)
        eval(['global ' fields{ik_}]);
        if ~eval('isempty(res.(fields{ik_}))')
            eval([fields{ik_} '=res.(fields{ik_});']);
        end
    end
end
       