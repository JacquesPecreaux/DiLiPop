function threshold = shanbhag_threshold(Imagee,imhist_nb)
            [count,X]=imhist_over(Imagee,imhist_nb);
            total=sum(count);
            norm_histo=count/total;
            P1=cumsum(norm_histo);
            P2=1-P1;
            first_bin = find(P1~=0,1,'first');
            if isempty(first_bin)
                first_bin=1;
            end
            last_bin = find(P2~=0,1,'last');
            if isempty(last_bin)
                last_bin=length(P2);
            end
            termBack=0.5./P1(first_bin:last_bin);
            termObj=0.5./P2(first_bin:last_bin);
            ent_back = nan(length(P1),1);
            ent_obj = nan(length(P1),1);
            for it=first_bin:last_bin
                ent_back(it) = -sum(norm_histo(2:it) .* ...
                    log(1-termBack(it-first_bin+1)*P1(1:(it-1))));
            end
            ent_back(first_bin:last_bin) = ent_back(first_bin:last_bin) .* termBack;
            for it=first_bin:last_bin
                ent_obj(it) = -sum(norm_histo((it+1):end) .* ...
                    log(1-termObj(it-first_bin+1)*P2((it+1):end)));
            end
            ent_obj(first_bin:last_bin) = ent_obj(first_bin:last_bin) .* termObj;
            tot_ent = abs(ent_back - ent_obj);
            [~,pos_threshold] = min(tot_ent);
            pos_threshold = pos_threshold + first_bin + 1;
            threshold = X(pos_threshold);
end