function new_working_dir(folder,tmpdir)
    global working_folder_orig;
    global working_folder_tmp;
    working_folder_orig = folder;
    if nargin<2 || isempty(tmpdir) || ~exist(tmpdir,'dir')
        working_folder_tmp = new_working_tmp_dir(working_folder_orig);
        disp(['working dir cache is "' working_folder_tmp '" to be moved finally to "' working_folder_orig '"']);
    else
        disp(['temporary folder was already existing, I know now where to move it :-) meaning in "' working_folder_orig '"']);
        working_folder_tmp=new_working_tmp_dir(working_folder_orig,tmpdir);
    end
    if isdeployed && java.lang.System.getenv().containsKey('ON_CLOSING_SCRIPT') && ~isempty(char(java.lang.System.getenv().get('ON_CLOSING_SCRIPT')))
        fid = fopen(char(java.lang.System.getenv().get('ON_CLOSING_SCRIPT')),'a');
        fprintf(fid,'WD_ORIG="%s"\nWD_TMP="%s"\n',working_folder_orig,working_folder_tmp);
        fclose(fid);        
    end
    [st,out] = system(['ln -s "' working_folder_tmp '" "' working_folder_orig '"']);
    if st~=0
        warning_perso('Failed to create the symlink in working_dir with error:\n%s',out);
    end
    disp('I created a symlink for now for convenience');
end