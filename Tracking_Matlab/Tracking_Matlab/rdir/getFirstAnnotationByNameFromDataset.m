function a = getFirstAnnotationByNameFromDataset(candidateDatasetID, annotationName)
    global session;
    annotations = getDatasetFileAnnotations(session,str2num(candidateDatasetID),'owner',-1);
    for idx = 1:length(annotations)
        a = annotations(idx);
        if ~isempty(a.getFile())
            candidateMaskName = a.getFile().getName().getValue();
            if strcmp(candidateMaskName,annotationName)
                return
            end
        end
    end
    a=[];
end