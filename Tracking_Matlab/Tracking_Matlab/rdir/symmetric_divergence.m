function [SD,bins,edges,H]=symmetric_divergence(original,processed,edges,bins,nbins)
    if exist('nbins','var') && ~isempty(nbins)
        [H,bins,edges]=pair_histogram_preserved(original,processed,nbins);
    elseif exist('bins','var') && ~isempty(bins)
        [H,bins,edges]=pair_histogram_preserved(original,processed,bins);
    elseif exist('edges','var') && ~isempty(edges)
        [H,~,edges]=pair_histogram_preserved(original,processed,[],edges);
    end
    
    %% compute marginal pdfs from Zhu and Cochoff, Biomedical Image
    %% Analysis 2003
    ho=sum(H,2);
    hp=sum(H,1);
    tmp=ho*hp;
    ll=log(H./tmp);
    ll(~isfinite(ll))=0; % because some bins are not populated
    SD=sum(sum((H-tmp).*ll));
end