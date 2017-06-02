function h = getFisherVector(all, means, covariances, priors,pcamap,pcaFactor,frm_indx)  
    comps = pcamap(:,1:size(pcamap,1)*pcaFactor);
    h = vl_fisher((all(frm_indx,:)*comps)', means, covariances, priors);
end