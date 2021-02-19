    function [val]=load_var_helper(childNode,initialise)
        function load_var_helper2(par)
               future_field=char(childNode.getTagName);
                %TODO validate field name
               if isvarname(future_field)
%                    if isfield(check_doublon,future_field)
%                        warning_perso('field %s appears multiple time! use the first one only',future_field);
%                    end
                       check_doublon.(future_field)=[];
                       if isa(par,'org.apache.xerces.dom.DeferredElementImpl') || ( exist('val','var') && isfield(val,future_field))
                           if ~( exist('val','var') && isfield(val,future_field))
                               val.(future_field)=cell(0);
                           else
                               temp=val.(future_field);
                                if ~iscell(temp) % needed to create the cell array
                                   temp2=cell(1);
                                   temp2{1}=temp;
                                   temp=temp2;
                                   if ~isa(par,'org.apache.xerces.dom.DeferredElementImpl')
                                        temp{2}=par;
                                   end
                               else
                                   if ~isa(par,'org.apache.xerces.dom.DeferredElementImpl')
                                        temp{length(val.(future_field))+1}=par;
                                   end
                               end
                                val.(future_field)=temp;
                           end
                       else
                           val.(future_field)=par;
                       end
               else
                   if (initialise==1)
                       warning('found (in model.xml) a field with invalid name %s - skipping',future_field);
                   else
                        warning('found (in processed xml file) a field with invalid name %s - skipping',future_field);
                   end
               end
        end % end of subsubfct
       while ~isempty(childNode)
          %Filter out text, comments, and processing instructions.
          if (initialise~=1 && (childNode.getNodeType == childNode.ELEMENT_NODE) && isempty(childNode.getFirstChild.getNextSibling))
               % Assume that each element has a single
               % org.w3c.dom.Text child.
               load_var_helper2(GetElementVal(childNode));
           elseif ((childNode.getNodeType == childNode.ELEMENT_NODE) && ~isempty(childNode.getFirstChild.getNextSibling))
               load_var_helper2(load_var_helper(childNode.getFirstChild,initialise));
           elseif (initialise==1 && (childNode.getNodeType == childNode.ELEMENT_NODE) && isempty(childNode.getFirstChild.getNextSibling))
             load_var_helper2([]);
          end
          childNode = childNode.getNextSibling;
       end  % End WHILE
    end
