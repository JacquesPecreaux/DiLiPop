function [param_,general_param_]=load_var_sub(childNode,initialise)
    global work_path;
%     global param;
    global status;
    if ~exist('initialise','var')
        initialise=0;
    end
%%

    if (initialise>=1)
        docNode= xmlread('model.xml');
        work_path_List=docNode.getElementsByTagName('General_Params');
        work_path_Node=work_path_List.item(work_path_List.getLength-1);
        childNode = work_path_Node.getFirstChild;
    end
    param_=load_var_helper(childNode,initialise);
    if (initialise>=1) % works only with previous lines
        general_param_=param_;
        allListItems = docNode.getElementsByTagName('Embryo');
        thisListItem = allListItems.item(0);
        childNode = thisListItem.getFirstChild;
        param_=load_var_helper(childNode,initialise);
    else
        general_param_=[];
    end
end


