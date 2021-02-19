function omero_init(username,password,server, group, encrypted_)
    % check for left-over keepalive timer
    info_perso('Seeking and clearing old keep alive timer before proceeding');
    % important to leave this info_perso to avoid that the first XYZ_perso
    % call would be from a static workspace
    findKillOmeroTimers;
    global session;
    session = [];
%     global session_unclear;
%     session_unclear = [];
    global client;
    client = [];
    global sc_idx;
    sc_idx = [];
    global secure_client;
    secure_client = [];
    global secure_session;
    secure_session = [];
    global clientAliveSemaphore
    clientAliveSemaphore = [];
    global clientAlive;
    clientAlive = [];
    global no_omero;
    if nargin>0 && ~isempty(username) && ischar(username)
        if strcmp(username, '[]')
            username=[];
        elseif strcmpi(username, 'nan')
            username=nan;
        end           
    end
    if nargin==0 || (~isempty(username) && isnumeric(username) && isnan(username))
        username = input('User name for omero database (empty=no omero)?','s');
    end
    if isempty(username)
        no_omero=1;
        return;
    else
            bfCheckJavaPath(1); % need to load bioFormats class here if not, the omero objects will prevent to do it at run time
    end
    no_omero=0;
    clientAliveSemaphore=javaObject('java.util.concurrent.Semaphore',1);
    clientAliveSemaphore.acquire();
    if nargin~=0 
        disp(['Current omero user is ' username]);
    end
    if isempty(username)
        return;
    end
    if isempty(username)
        disp('skipping omero login');
        return;
    end
    if nargin<2 || isempty(password)
        if ~ispc
            fprintf('Password:'); %mind that this sentence is expected by multiplejob / Pexpect
            [s,password] = system('bash -c ''read -s PASS ; echo -n $PASS''');
            fprintf('\n');
            if s~=0
                warning('I am unsure I got your password correctly');
            end
            if strfind(password,newline)==1
                warning('There is a leading new line in the password. Discarding');
                password=password(2:end);
            end
            if ~isdeployed && ~isempty(strfind(password,newline))
                warning('Something suspect happens ! Password contains multiple lines (are you currently in a dir that exists ?) ! Revert to old behavior');
                s=1;
                password=[];
            end
        else
            s=1;
        end
    else
        if strcmp(password,'_expect_provided_password_')
            info_perso('special value of password enabling to provide it programmatically');
            diary off
            password =  input('Password:','s');
            diary on
        end
        s=0;
    end
    if s~=0
        password = passwordUI();
    end
    if nargin<3 || isempty(server)
        server = input('Server [cedre-5a.med.univ-rennes1.fr]?','s');
        if isempty(server)
            server='cedre-5a.med.univ-rennes1.fr';
        end
    end
    % username,password,server, omero_use_original_, group, encrypted_
    if nargin>=5 && ischar(encrypted_)
        encrypted_ = str2double(encrypted_);
    end

    map=javaObject('java.util.HashMap');
    map.put('omero.user',username);
    map.put('omero.pass',password);
	if nargin>=4
		map.put('omero.group',group);
	else
		%map.put('omero.group',[]);
	end
    map.put('omero.host',server);
    map.put('omero.port',int16(4064));
    
    if nargin<5 || isempty(encrypted_) 
        encrypted_ = input('Use encrypted connexion (slower but more secure) [0=no, 1 =yes, default = no]?');
        if isempty(encrypted_)
            encrypted_= false;
        else
            encrypted_=logical(encrypted_);
        end
    else
        encrypted_ = logical(encrypted_);
    end
    ChoosenGroup = omero_init_helper_secured(map, encrypted_);
    if nargin<4
        map.put('omero.group',ChoosenGroup);
    end
    disp(['Using omero version ' omeroVersion]);

    global omero_use_original;
    omero_use_original=0; % fonctionnality no longer maintained, particularly in omero 5

    global encrypted
    encrypted = encrypted_;
    
    global mapBkp;
    mapBkp = map;
    
    global temp_dir;
    temp_dir = tempname;
    mkdir_perso(temp_dir);
    
    global ChoosenGroup_;
    ChoosenGroup_=ChoosenGroup;
    
end
