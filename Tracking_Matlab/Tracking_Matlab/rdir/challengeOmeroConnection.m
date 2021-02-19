function challengeOmeroConnection
    global clientAlive
    global clientAliveSemaphore
    global client;
    global countReconnectionAttempt;
    if isempty(client) && isempty(clientAlive) && isempty(clientAliveSemaphore)
        omero_init;
    else
        try
            omero_session = client.getSession();
            omero_session.keepAlive([]);
            countReconnectionAttempt=0;
        catch EX
            warning_perso('Omero session seem lost. Call keep Alive to restore if possible');
            clientAliveSemaphore.acquire();
            if ~isempty(clientAlive) && isvalid(clientAlive) % if not valid, it means that is it already reconnecting.
                stop(clientAlive);
                start(clientAlive);
                wait_=get(clientAlive,'StartDelay')+2;
                clientAliveSemaphore.release();
                pause(wait_);
            end           
        end
    end
end