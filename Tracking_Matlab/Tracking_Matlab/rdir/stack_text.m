    function [result]=stack_text(stack)
        if ~isempty(stack)
            for ind=1:length(stack)
                if (ind==1)
                    result=sprintf('\tFILE : %s FUNCTION : %s LINE : %d',stack(ind).file,stack(ind).name,stack(ind).line);
                else
                    result=sprintf('%s\n\tFILE : %s FUNCTION : %s LINE : %d',result,stack(ind).file,stack(ind).name,stack(ind).line);
                end
            end
        else
            result='Empty Stack -:(';
        end
    end
