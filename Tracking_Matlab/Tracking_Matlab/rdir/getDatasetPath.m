function [pathstr, candidateDatasetID, candidateFormat ] = getDatasetPath(datasetIDstr, createDirs)
    global session
    global general_param
    global path_from_omero;
    global param;
    %% simulations
    if param.sim_>=1
        pathstr=fullfile(param.basepath,short_name);
        candidateDatasetID=[];
        candidateFormat=[];
        return
    end
    %%
        candidate=regexp(datasetIDstr,'\.','split');
        candidateDatasetID=candidate{1};
        if length(candidate)>=2
            candidateFormat=candidate{2};
        else
            candidateFormat='omero_generic';
        end
        if isnan(str2double(candidateDatasetID))
            disp([datasetIDstr ' seems not in DatasetID.format shape -- skipping']);
            pathstr=[];
            candidateDatasetID=[];
            candidateFormat=[];
            return;
        end
    %% fallback when running Fourier or others without omero
    global clientAlive
    global clientAliveSemaphore
    global client;
    global mapBkp; % to be sure we have not simply lost the connection.
    global save_stem_g;
    if isempty(client) && isempty(clientAlive) && isempty(clientAliveSemaphore) && isempty(mapBkp)
        [~,PID_name]=fileparts(param.basepath);
        if ~isempty(save_stem_g) && exist(fileparts(save_stem_g),'dir')
            p=fileparts(save_stem_g);
        else
            p=get_working_dir();
        end
        p=fullfile(p,PID_name);
        if ~exist(p,'dir')
            mkdir(p);
        end
        pathstr = fullfile(p,param.sp1);
        if ~exist(pathstr,'dir')
            mkdir(pathstr);
        end
        return
    end
    %% case with omero

        query = ['select d from Dataset d ' ...
            'join fetch d.projectLinks pl ' ...
            'join fetch pl.parent ' ...
            'where d.id = ' candidateDatasetID];
        challengeOmeroConnection;
        datasets = session.getQueryService().findAllByQuery(query,[]);
        if datasets.isEmpty
            warning_perso(['Are you sure the dataset with id ' candidateDatasetID ' exist ? I cannot find it and will skip this embryo!']);
            pathstr=[];
            return;
        end
        dataset = datasets.get(0);
        candidateDatasetName = char(dataset.getName().getValue());
        datasetDir = [candidateDatasetID '__' candidateDatasetName];
        % line below needed apparently to avoid omero.UnloadedCollectionException: Error updating collection:projectLinksSeq

        datasetLinks = dataset.iterateProjectLinks();
        if datasetLinks.hasNext()
            project = datasetLinks.next().getParent();
        end
        if datasetLinks.hasNext()
            disp('Seems that the dataset is linked to multiple projec, taking the first one');
        end
        candidateProjectID = project.getId().getValue();
        candidateProjetName = char(project.getName().getValue());
        projectDir = [num2str(candidateProjectID,'%d') '__' candidateProjetName];
        pathstr = fullfile(general_param.data_project_dir,projectDir);
        create_link_dir(createDirs,pathstr,candidateProjectID,projectDir);
        pathstr = fullfile(pathstr,datasetDir);
        path_from_omero = pathstr;
        create_link_dir(createDirs,pathstr,candidateDatasetID,datasetDir);
end
