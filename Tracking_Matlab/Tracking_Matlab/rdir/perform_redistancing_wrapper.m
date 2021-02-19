function [phi] = perform_redistancing_wrapper(phi, ~, ~, ~, ~, ~)
    if size(phi,1)==size(phi,2)
        phi2=phi;
    else
        m=max(size(phi));
        phi2=-ones(m,m);
        phi2(1:size(phi,1),1:size(phi,2))=phi;
    end
    
    phi2=perform_redistancing(phi2);
    if size(phi,1)==size(phi,2)
        phi=phi2;
    else
        phi=phi2(1:size(phi,1),1:size(phi,2));
    end
end