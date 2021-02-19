function I= get_from_original_file_from_Pixels(pixelsId,index)
    global session;
    query = ['select ofile from OriginalFile as ofile left join ' ...
                       'ofile.pixelsFileMaps as pfm left join pfm.child as ' ...
                       'child where child.id = ' num2str(pixelsId,'%d')];
    % see http://www.openmicroscopy.org/community/viewtopic.php?f=6&t=405               
    
    %     query = ['select ial from ImageAnnotationLink as ial join fetch ial.child as ann join fetch ann.file as file where ial.parent = ' num2str(imageId,'%d')];
    files = session.getQueryService().findAllByQuery(query,[]);
    originalFile = files.get(0);
    name = char(originalFile.getName().getValue());
    
    %% create path for the original file
    global temp_dir;
    
    query = ['select i from Image i left outer join fetch i.pixels as pixels ' ... 
        'where pixels.id = ' num2str(pixelsId,'%d')];
    images = session.getQueryService().findAllByQuery(query,[]);
    imageId = images.get(0).getId().getValue();
    if images.size() > 1 
        warning_perso(['in downloading original file, more than one image use pixels with id = ' ...
            num2str(pixelsId,'%d') '. I took the first one']);
    end
    query = ['select d from Dataset d left outer join fetch d.imageLinks as links ' ...
        'left outer join fetch links.child as child ' ...
        'where child.id = ' num2str(imageId,'%d') ];
    datasets =  session.getQueryService().findAllByQuery(query,[]);
    datasetId = datasets.get(0).getId().getValue();
    if images.size() > 1 
        warning_perso(['in downloading original file, more than one dataset use image with id = ' ...
            num2str(imageId,'%d') '. I took the first one']);
    end
    query = ['select p from Project p left outer join fetch p.datasetLinks as links ' ... 
        'left outer join fetch links.child as child ' ...
        'where child.id = ' num2str(datasetId,'%d') ];
    projects =  session.getQueryService().findAllByQuery(query,[]);
    projectId = projects.get(0).getId().getValue();
    if images.size() > 1 
        warning_perso(['in downloading original file, more than one project use dataset with id = ' ...
            num2str(datasetId,'%d') '. I took the first one']);
    end

    dest=fullfile(temp_dir, ...
        fullfile(num2str(projectId,'%d'), ...
        fullfile(num2str(datasetId,'%d'), ...
        fullfile(num2str(imageId, '%d'), num2str(pixelsId,'%d')))));
    
    %% test if the file was already downloaded
    fname = fullfile(dest, name);
    % TODO: test integrity of the file
    if ~exist(fname,'file')
        f1=fullfile(temp_dir, fullfile(num2str(projectId,'%d')));
        if ~exist(f1,'dir')
            mkdir_perso(f1);
        end
        f2=fullfile(f1, fullfile(num2str(datasetId,'%d')));
        if ~exist(f2,'dir')
            mkdir_perso(f2);
        end
        f3=fullfile(f2, fullfile(num2str(imageId,'%d')));
        if ~exist(f3,'dir')
            mkdir_perso(f3);
        end
        f4=fullfile(f3, fullfile(num2str(pixelsId,'%d')));
        if ~exist(f4,'dir')
            mkdir_perso(f4);
        end
        %% retrieve the file if it does not exist
        retrieve_original_file(originalFile, dest, name );
    end
    
    I = imread(fname, index);
end