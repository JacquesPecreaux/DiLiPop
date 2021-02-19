function str = param2str(param,varargin)
    if nargin>1
        indent=varargin{1};
    else
        indent=0;
    end
    str='';
    
    switch class(param)
        case 'struct'
            % get the list of field and compute lengths
            fields=fieldnames(param);
            lengths=zeros(length(fields),1);
            for i=1:length(fields)
                lengths(i)=length(fields{i});
            end
            cur_indent=indent+1+max(lengths);
            
            for i=1:length(fields)
                str=[str sprintf('\n') ' '*ones(1,cur_indent-1-length(fields{i})) fields{i} ':' param2str(param.(fields{i}),cur_indent)];
            end
            
        case 'cell'
            if ndims(param)>2 || numel(param)>200
                tmp=['Cell Array of size='];
                str=[tmp param2str(size(param),cur_indent+length(tmp))];
            elseif numel(param)>1
                str = param2str_helper(param,0,indent);
            else
                str = param2str(param{1});
            end
        case 'char'
            str=[str '"' param '"'];
        case 'function_handle'
            str=[str '@' func2str(param)];
        case {'logical','int8','int16','int32','int64','uint8','uint16','uint32','uint64','single','double'}
            if ndims(param)>2 || numel(param)>200
                tmp=['Array of ' class(param) ' size='];
                str=[tmp param2str(size(param),cur_indent+length(tmp))];
            elseif numel(param)>1
                str = param2str_helper(param,0,indent);
            else
               switch class(param)
                   case 'logical'
                        str=sprintf('%1d',param);           
                   case {'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
                       if param>=1e9 || param<=-1e8
                           str=sprintf('% 8g',double(param));
                       else
                           str=sprintf('% 8d',param);
                       end
                   case {'single', 'double'}
                       str=sprintf('% 8g',param);
               end
            end
        otherwise % assume it's a java class
            str=param.toString();
    end
end