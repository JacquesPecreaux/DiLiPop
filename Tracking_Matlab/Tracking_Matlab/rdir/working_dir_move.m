function working_dir_move(varargin)
    global working_folder_orig;
    global working_folder_tmp;
    global upper_fct;
    if nargin>=1
        working_folder_orig=varargin{1};
    end
    if ~isempty(working_folder_tmp) && isempty(working_folder_orig)
        warning_perso(['I cached results to "' working_folder_tmp '" but was never said where to put these at the end. I put it in home folder']);
        [~,name]=fileparts(working_folder_tmp);
        working_folder_orig=fullfile(get_home,name);
    end
    if ~isempty(working_folder_tmp) && ~isempty(working_folder_orig)
        if exist(working_folder_tmp,'dir')
            if exist(working_folder_orig,'dir')
                system(['if test -h "' working_folder_orig '" ; then unlink "' working_folder_orig '" ; fi']);
            end
            if ~exist(working_folder_orig,'dir')
%                 [idum,hostname]= system('hostname');
%                 hostname = strtrim(hostname);
%                 if (strcmp(hostname, 'CEDRE-16' ) == 1)
%                     working_folder_orig = ['/home/yann' working_folder_orig];
%                 end
%                 movefile(working_folder_tmp,working_folder_orig);
%             else
                movefile(fullfile(working_folder_tmp,'*'),working_folder_orig);
                rmdir(working_folder_tmp);
%             end
            disp(['Moved cached working dir to "' working_folder_orig '"']);
        end
    end
    working_folder_orig=[];
    working_folder_tmp=[];
    upper_fct=[];

end
