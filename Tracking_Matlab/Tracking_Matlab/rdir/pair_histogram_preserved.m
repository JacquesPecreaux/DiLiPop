function [H,bins,edges]=pair_histogram_preserved(original,processed,bins_or_nbins,varargin)
    % images are supposed of the same dimension and pixels are matching (no
    % resampling)
    if numel(original)~=numel(processed) || (~isa(original,'double') && ~isa(original,'single') ) || (~isa(processed,'double') && ~isa(processed,'single') )
        error('pair_histogram_preserved expect a set of two double matching images (same sizes)');
    end
    if nargin<=3 || ~iscell(varargin{1})        
        if numel(bins_or_nbins)==1
            %% binning from Camp et Robb, SPIE 1999
            bins=quantile(original(:),0:(1/(bins_or_nbins-1)):1);
            bins(1)=-Inf;
            if length(bins)==(bins_or_nbins-1) || length(bins)==bins_or_nbins
                bins(bins_or_nbins)=Inf;
            else
                error('binning does not give the right size for bins vector'); 
            end
            
            bins2=quantile(processed(:),0:(1/(bins_or_nbins-1)):1);
            bins2(1)=-Inf;
            if length(bins2)==(bins_or_nbins-1) || length(bins2)==bins_or_nbins
                bins2(bins_or_nbins)=Inf;
            else
                error('binning does not give the right size for bins vector'); 
            end
            
        else
            bins=bins_or_nbins;
        end
    %% histogram from Pluim et al., IEEE 2003
        edges=cell(2,1);
        edges{1}=bins;
        if exist('bins2','var') && length(bins2)==bins_or_nbins
            edges{2}=bins2;
        else
            edges{2}=bins;
        end
    else
        edges=varargin{1};
        bins=[];
    end
    N=hist3(cat(2,reshape(original,numel(original),1),reshape(processed,numel(processed),1)),'edges',edges);
    H=N/sum(sum(N));
end
