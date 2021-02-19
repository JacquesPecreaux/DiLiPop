function ChoosenGroup=omero_init_helper(map,varargin)
%     disp('omero_init_helper called with args')
%     disp('******** map ********');
%     disp(map);
%     disp('******** varargin *********');
%     for ik =1:length(varargin)
%         disp(['varargin{' ik '} = ' varargin{ik} ]);
%     end

    
    [secure_client_,secure_session_] = loadOmero_helper(map); 
    if varargin{1}
        client_ = secure_client_;
        session_ = secure_session_;
    else
        client_ = secure_client_.createClient(false); % Checked 5.4.0
        session_ = client_.getSession();  % Checked 5.4.0
    end
%%
    sc = session_.getSecurityContexts();
    shs = session_.getShareService();
    %%
    if nargin<=2
        csc = [];
        name = [];
        for ii_=0:(sc.size()-1)
            if isa(sc.get(ii_),'omero.model.ExperimenterGroupI')
                sc_name = char(sc.get(ii_).getName().getValue());
                fprintf('%d. Group -> %s\n',ii_+1,sc_name);
            elseif isa(sc.get(ii_),'omero.model.ShareI')
                sc_name = ['Id = ' num2str(sc.get(ii_).getId().getValue())];

                members = shs.getAllMembers(sc.get(ii_).getId().getValue());
                strMembers=[];
                for jj_=0:(members.size()-1)
                    strMembers = [ strMembers char(members.get(jj_).getOmeName().getValue()) ','];
                end
                strMembers = strMembers(1:(end -1 ));
                fprintf('%d. Share ->  %s Owner: %s   Members: %s\n',ii_+1,sc_name,char(sc.get(ii_).getOwner().getOmeName().getValue()),strMembers);
            else
                fprintf('NOT IMPLEMENTED SECURITY CONTEXT ->  %s\n',class(sc.get(ii_)));
            end
            if ~isempty(map.get('omero.group')) && strcmpi(sc_name,map.get('omero.group'))
                 csc = sc.get(ii_);
                 break;
            end
        end
        if isempty(map.get('omero.group'))
            ii_ = 0;
        end
        sc_idx_ = ii_ +1;
        if isempty(csc)
            csc = sc.get(0);
            sc_idx_ = input_perso('Which group would you like to use (number)',sc_idx_);
            csc = sc.get(sc_idx_-1);
         end
    else
        sc_idx_ = varargin{2};
        csc = sc.get(sc_idx_-1);
    end
    ChoosenGroup=csc.getName().getValue();
    session_.setSecurityContext(csc);
%     %necessary to keep the proxy alive. part of the omero-package
    clientAlive_ = omeroKeepAlive(client_);
    %%

    %%

    global session;
    session = session_;
%     global session_unclear;
%     session_unclear = session;
    global client;
    client = client_;
    global sc_idx;
    sc_idx = sc_idx_;
    global secure_client;
    secure_client = secure_client_;
    global secure_session;
    secure_session = secure_session_;
    global clientAlive;
    clientAlive = clientAlive_;
end
