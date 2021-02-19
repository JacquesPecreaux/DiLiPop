function create_link_dir(createDirs,pathstr,candidateProjectID,projectDir)
        if createDirs
            if ~exist(pathstr,'dir')
                contain = fileparts(pathstr);
                %did it change name
                p = dir(fullfile(contain,[num2str(candidateProjectID,'%d') '__*' ]));
                if ~isempty(p)
                    if ispc
                        error('creating link not yet implemented');
                    else
                        if length(p)>1
                            pp=[];
                            for ii_=1:length(p)
                                [~, t] = system(['if test -L "' ...
                                    fullfile(contain,p(ii_).name) '"; then echo -n 1 ; else echo -n 0 ; fi']);
                                if strcmp(t,'0')                                   
                                    pp=p(ii_).name;
                                else
                                    [~, t] = system(['if test -d "' ...
                                    fullfile(contain,p(ii_).name) '"; then echo -n 1 ; else echo -n 0 ; fi']);
                                    if strcmp(t,'0')
                                        warning_perso(['Symlink ' p(ii_).name ' seems dead! unlinking']);
                                        [~, t] = system(['unlink "' ...
                                    fullfile(contain,p(ii_).name) '"']);
                                    end
                                end
                            end
                            if isempty(pp)
                                warning_perso('create a symlink to project, pointing to a link!');
                                pp=p(1).name;
                            end
                        else
                            pp = p(1).name;
                        end
                        [~,pathstr_]=fileparts(pathstr);
                        secure_make_symlink(contain,pathstr_,pp);
                    end
                else
                    mkdir_perso(pathstr);
                end
            end
        end
end