function working_folder_tmp = new_working_tmp_dir(wdo,working_folder_tmp)
        global upper_fct;
        [~,tmpname] = fileparts(tempname);
        if nargin<1
            wdo=[datestr(now,'yyyy-mm-dd__HH-MM-SS') '__no_name'  ];
            disp('I create the cache for the working dir but I don''t know so far where to move it at the end');
        end
        if nargin<2
            working_folder_tmp = fullfile(tempdir,tmpname,wdo);
        end
        upper_fct=get_upper_fct;
        if ~exist(working_folder_tmp,'dir')
            mkdir_perso(working_folder_tmp);
        end
end