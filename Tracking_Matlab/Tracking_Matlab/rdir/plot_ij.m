function plot_ij(varargin)
    global Imagee;
%     tmp=size(Imagee,1)-varargin{1}+1;
    tmp=varargin{1};
    varargin{1}=varargin{2};
    varargin{2}=tmp;
    plot_perso(varargin{:});
end