function str = param2str_helper(param,cell_or_array,indent)
                       str='';
                       if size(param,1)>1
                                if cell_or_array
                                    str= '{ ';
                                else
                                    str= '[ ';
                                end
                       end
                       for ii=1:size(param,1)
                           if size(param,2)>1
                               if cell_or_array
                                   str=[str '{ '];
                               else
                                   str=[str '[ '];
                               end
                           end
                           for jj=1:size(param,2)
                               if cell_or_array
                                    str=[str param2str(param{ii,jj}) ' '];
                               else
                                    str=[str param2str(param(ii,jj)) ' '];
                               end
                           end
                           if size(param,2)>1 
                               if cell_or_array
                                   str=[str '} '];
                               else
                                   str=[str '] '];
                               end
                               if jj<size(param,2)
                                   str=[str sprintf('\n') ' '*ones(1,indent)];
                               end
                           end
                       end
                       if size(param,1)>1
                           if cell_or_array
                               str=[str ' }'];
                           else
                               str=[str ' ]'];
                           end
                       end
