function cwd = get_working_dir(wd)
%#function onCleanup_helper
    global working_folder_orig;
    global working_folder_tmp;
    if nargin>=1 && ~isempty(wd) && ~java.io.File(wd).isAbsolute()
        wd=fullfile(pwd,wd);
    end
    
    if nargin>=1 && ~isempty(working_folder_orig) && ~strcmp(wd,working_folder_orig)
        working_dir_move;
        disp('working_dir_move');
    end
    if (nargin>=1 && isempty(working_folder_orig)) ||  ...
            (nargin<1 && ~isempty(working_folder_orig) && (isempty(working_folder_tmp) || ~exist(working_folder_tmp,'dir')))
        if (nargin<1 && ~isempty(working_folder_orig))
            disp('Temp folder appeared to have been moved prematurely or in a weird fashion');
            wd=working_folder_orig;
        else
            disp('New WD');
        end        
        new_working_dir(wd,working_folder_tmp);
        if ~isdeployed || ~java.lang.System.getenv().containsKey('ON_CLOSING_SCRIPT') || isempty(char(java.lang.System.getenv().get('ON_CLOSING_SCRIPT')))
            start(timer_perso(working_folder_orig,'BusyMode','drop','ExecutionMode','fixedRate','Name','Working Dir Cache',...
                'Period',1,'StartDelay',1,'TimerFcn',@cache_working_dir_timer));
            evalin('base','working_dir_cache_on_cleanup=onCleanup(@onCleanup_helper);'); % needed for compiled code
        end
        Version_perso( mfilename('fullpath'),true);
        % the script is writen in new_working_dir
    elseif (isempty(working_folder_tmp) || ~exist(working_folder_tmp,'dir')) && nargin<1 
        disp('Creating only temp WD');
        working_folder_tmp = new_working_tmp_dir;
        Version_perso( mfilename('fullpath'),true);
    end
    cwd=working_folder_tmp;
end