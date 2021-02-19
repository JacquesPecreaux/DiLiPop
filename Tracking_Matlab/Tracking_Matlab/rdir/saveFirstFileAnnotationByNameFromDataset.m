function path = saveFirstFileAnnotationByNameFromDataset(candidateDatasetID, annotationName,dest)
    global session;
    
    fa = getFirstAnnotationByNameFromDataset(candidateDatasetID, annotationName);
    if isempty(fa)
        error('Cannot retrieve annotation named "%s" in dataset #%d. Are you sure that this mask exist ?s',annotationName,candidateDatasetID);
    end
    path = fullfile(dest,annotationName);
    getFileAnnotationContent(session, fa, path);
end
    
