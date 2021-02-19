function [result]=input_perso(varargin)
    persistent cumul_question
    persistent cumul_type
    persistent cumul_default
    
    function [res]=test_empty(res_in,def)
        if isempty(res_in)
            res=def;
        else
            res=res_in;
        end
    end

    function res = doInput(varargin)
        % text, type
        global input_2016b_bug_workaround
        if ~isempty(input_2016b_bug_workaround) && input_2016b_bug_workaround
            cumul_question = [cumul_question { varargin{1}}];
            if nargin>1
                cumul_type = [cumul_type {varargin{2}}];
            else
                cumul_type = [cumul_type {'n'}];
            end
            if nargin>2
                if ~ischar(varargin{3})
                    defrep = num2str(varargin{3});
                else
                    defrep = varargin{3};
                end
                cumul_default = [cumul_default {defrep}];
            else
                cumul_default = [cumul_default {[]}];
            end
            if input_2016b_bug_workaround == 2
                resArray = inputdlg(cumul_question,'input workaround (empty editbox => default value)',1,cumul_default);
                res = cell(1,length(resArray));
                for ij = 1:length(resArray)
                    fprintf('Question copy:%s\nAnswer copy:%s\n',cumul_question{ij},resArray{ij});
                    switch cumul_type{ij}
                        case 's'
                            res{ij}=resArray{ij};
                        case 'n'
                            res{ij}=str2num(resArray{ij});
                        otherwise
                            error('unknown input type %s',cumul_type{ij});
                    end
                end
                cumul_type =[];
                cumul_question = [];
                cumul_default=[];
            else
                res = [];
            end    
        else
            if nargin>1 && strcmp(varargin{2},'s')
                res = input(varargin{1},'s');
            else
                res = input(varargin{1});
            end
            if nargin>2
                res=test_empty(res,varargin{3});
            end
        end
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch nargin
        case 1
            result=doInput(varargin{1});
        case 2
            if strcmp(varargin{2},'s')
                result=doInput(varargin{1},'s');
            elseif strcmp(varargin{2},'a')
                result=doInput(varargin{1},'s');
                result=str2double(result);
            else
                if ischar(varargin{2})
                    result=doInput([ varargin{1} ' (default=' varargin{2} ') ?'],'s',varargin{2});
                else
                    if all(round(varargin{2})==varargin{2})
                        result=doInput([ varargin{1} ' (default=[ ' sprintf('%d ',varargin{2}) ']) ?'],'n',varargin{2});
                    else
                        result=doInput([ varargin{1} ' (default=[ ' sprintf('%g ',varargin{2}) ']) ?'],'n',varargin{2});
                    end
                end
            end
        case 3
            if strcmp(varargin{2},'s')
                result=doInput([ varargin{1} ' (default=' varargin{3} ') ?'],'s',varargin{3});
            elseif strcmp(varargin{2},'a')
                result=doInput([ varargin{1} ' (default=' num2str(varargin{3}) ') ?'],'s',varargin{3});
            end
    end
end

            
        
    