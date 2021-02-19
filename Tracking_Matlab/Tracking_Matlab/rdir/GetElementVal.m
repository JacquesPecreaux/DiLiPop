    function [val]=GetElementVal(childNode)
         childText = char(childNode.getFirstChild.getData);
         [token, remain]=strtok(childText, '>>');
         remain(1:2)=[];
         if strcmp(token,'num')
             val=str2num(remain);
         elseif strcmp(token,'array')
%              if isempty(strfind(remain,'[')) && isempty(strfind(remain,';'))
%                 valtmp=textscan(remain,'%f\t');
%                 val=valtmp{1};
%              else
                 val=str2num(remain);
%              end
         elseif strcmp(token,'text')
             val=char(remain);
         elseif strcmp(token,'fun')
             if ~isempty(remain)
                val=str2func(remain);
             else
                 val=[];
             end
         elseif strcmp(token,'end_cell')
             val = childNode;
         else
             error('JACQ:UKNOWNXMLTYPE','unknown type of data encountered in xml file');
         end
    end
