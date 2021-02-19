function docNode=write_replace_entry(docNode,thisListItem,pname,pvalue,varargin)
        
        if nargin<5
            direct=0;
        else
            direct = varargin{1};
        end
        if nargin<6
            index = [];
        else
            index = varargin{2};
        end
        if ~isempty(strfind(pname,'.'))
            % we passed something aimed to be a structured in an ill-way
            struct_fields = strsplit(pname,'.');
            pname2=struct_fields{1};
            pvalue2 =  pvalue;
            for ij_=length(struct_fields):-1:2
               tmp = struct();
               tmp.(struct_fields{ij_}) = pvalue2;
               pvalue2 = tmp;
            end
            docNode=write_replace_entry(docNode,thisListItem,pname2,pvalue2,varargin{:});
            return
        end
        
        if isempty(docNode)
            docNode=org.apache.xerces.dom.DeferredDocumentImpl();
        end
        if ~isempty(thisListItem)
            work_path_List=thisListItem.getElementsByTagName(pname);
        end
        if ~isempty(thisListItem) && ((work_path_List.getLength>=1) && (isempty(index) || (work_path_List.getLength>index))) %rely on short-circuiting! % index starts from 0!
            if isempty(index)
                work_path_Node=work_path_List.item(work_path_List.getLength-1);
            else
                work_path_Node=work_path_List.item(index);
            end
            if direct
                work_path_Node.replaceChild(docNode.createTextNode(pvalue),work_path_Node.getFirstChild);
            elseif ischar(pvalue)
                work_path_Node.replaceChild(docNode.createTextNode(['text>>' pvalue]),work_path_Node.getFirstChild);
            elseif ((length(pvalue)>1) && ~iscell(pvalue))
                rect_str=mat2str(pvalue);
                work_path_Node.replaceChild(docNode.createTextNode(['array>>' rect_str]),work_path_Node.getFirstChild);
            elseif isstruct(pvalue)
                fn=fieldnames(pvalue);
%                 docRootNode=docNode.getDocumentElement;
                for ij_=1:length(fn)
%                         Child_List=work_path_Node.getElementsByTagName();
%                         Child_Node=Child_List.item(Child_List.getLength-1);
                        write_replace_entry(docNode,work_path_Node,fn{ij_},pvalue.(fn{ij_}));
                end
            elseif iscell(pvalue)
                parent = work_path_Node.getParentNode;
                allItems = parent.getElementsByTagName(pname);
                array_length = allItems.getLength-1;
                for k = array_length:-1:0
                    allItems.item(k).getParentNode.removeChild(allItems.item(k));
                end
                for ij_=1:length(pvalue)
%                         Child_List=work_path_Node.getElementsByTagName(pname);
%                         Child_Node=Child_List.item(ij_-1); % numbered from 0
                        write_replace_entry(docNode,parent,pname,pvalue{ij_},0,ij_-1);
                end
                %create a last empty field to ensure that it will load as
                %a cell array even if there is one element.
                write_replace_entry(docNode,parent,pname,docNode.createTextNode(['end_cell>>' ]),0,length(pvalue));

            elseif isnumeric(pvalue) || islogical(pvalue)
                work_path_Node.replaceChild(docNode.createTextNode(['num>>' num2str(pvalue)]),work_path_Node.getFirstChild);
            elseif isa(pvalue,'function_handle')
                 work_path_Node.replaceChild(docNode.createTextNode(['fun>>' func2str(pvalue)]),work_path_Node.getFirstChild);
            elseif isa(pvalue,'org.apache.xerces.dom.TextImpl')
                work_path_Node.replaceChild(pvalue,work_path_Node.getFirstChild);
            else
                error('JACQ:WRITEXML','unknown type in xml conversion');
            end
        else
            if isempty(thisListItem)
                docNode.createDeferredDocument;
                thisListItem=docNode;
            end
            subEl=docNode.createElement(pname);
            if direct
                subEl.appendChild(docNode.createTextNode(pvalue));
            elseif ischar(pvalue)
                subEl.appendChild(docNode.createTextNode(['text>>' pvalue]));
            elseif ((length(pvalue)>1) && ~iscell(pvalue))
                rect_str=mat2str(pvalue);
                subEl.appendChild(docNode.createTextNode(['array>>' rect_str]));
            elseif isstruct(pvalue)
                fn=fieldnames(pvalue);
%                 docRootNode=docNode.getDocumentElement;
                for ij_=1:length(fn)
%                         thisElement = docNode.createElement(pname);
                        write_replace_entry(docNode,subEl,fn{ij_},pvalue.(fn{ij_}));
                end
            elseif iscell(pvalue)
%                 docRootNode=docNode.getDocumentElement;
                for ij_=1:length(pvalue)
                        write_replace_entry(docNode,thisListItem,pname,pvalue{ij_},0,ij_-1);
                end
            elseif isnumeric(pvalue) || islogical(pvalue)
                subEl.appendChild(docNode.createTextNode(['num>>' num2str(pvalue)]));
            elseif isa(pvalue,'function_handle')
                subEl.appendChild(docNode.createTextNode(['fun>>' func2str(pvalue)]));
            elseif isa(pvalue,'org.apache.xerces.dom.TextImpl')
                subEl.appendChild(pvalue);
            else
                error('JACQ:WRITEXML','unknown type in xml conversion');
            end
            if ~iscell(pvalue)
                thisListItem.appendChild(subEl);
            end
        end
end

    
