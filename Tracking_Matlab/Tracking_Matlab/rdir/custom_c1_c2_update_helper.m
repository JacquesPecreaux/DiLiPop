function [c1 c2]=custom_c1_c2_update_helper(custom_c1_c2_update,varargin)
     if length(varargin)>nargin(custom_c1_c2_update)           
          varargin((nargin(custom_c1_c2_update)+1):length(varargin))=[];
     end
     [c1 c2]=custom_c1_c2_update(varargin{:});
end