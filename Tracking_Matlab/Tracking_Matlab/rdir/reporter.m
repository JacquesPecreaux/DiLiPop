function reporter(status,error_,name)
            
global plot10;
% global plot10zoomed;
global work_path;

if (status==0)
    nom=sprintf('Processing file %s\n\n',name);
elseif (status>0)
    nom=sprintf('%s completed for %s\n',fct_num2text(status),name);
elseif length(error_.identifier)>=4 && strcmp(error_.identifier(1:4),'JACQ')
    nom=sprintf('%s aborded : %s\n\terror # %s : %s\n%s\n',fct_num2text(-status),name,error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
    disp(['CAUGHT KNOWN ERROR : ' nom]);
elseif length(error_.identifier)>=4
    nom=sprintf('%s failed : %s\n\terror # %s : %s\n%s\n',fct_num2text(-status),name,error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
    disp(['CAUGHT UNKNOWN ERROR : ' nom]);
elseif length(error_.identifier)<4
    nom=sprintf('%s unknown failed : %s\n\terror # %s : %s\n%s\n',fct_num2text(-status),name,error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
    disp(['CAUGHT UNTAGGED ERROR : ' nom]);
end

% disp(nom)
fid=fopen_perso(fullfile(get_working_dir,'reporter.log'),'a',1);
if (status==0)
    fprintf(fid,'\n\n%s : %s',datestr(now,'yyyy-mm-dd__HH-MM-SS'),nom);
else
    fprintf(fid,'%s : %s',datestr(now,'yyyy-mm-dd__HH-MM-SS'),nom);
end
fclose_perso(fid);


if ~isnan(status) && ~isempty(plot10)
    figure_perso(plot10);
    subplot_perso(7,10,[49:50 59:60]);
    axis([0 1 -16 0]); % instead of -8 formerly to squeeze the text above orientation thumbnails
    axis off;
    if (status~=0)
        if isempty(strfind(nom,'completed'))
            if isempty(strfind(nom,'aborded'))
                tmp=strfind(nom,'failed');
                tmp=tmp(1);
                text(0,-round(log(abs(status))/log(2)),nom(1:tmp),'FontSize',8,'Color','red');
            else
                tmp=strfind(nom,'aborded');
                tmp=tmp(1);
                text(0,-round(log(abs(status))/log(2)),nom(1:tmp),'FontSize',8,'Color',[1 0.7 0]);
            end
        else
            tmp=strfind(nom,'completed');
            tmp=tmp(1);
            text(0,-round(log(abs(status))/log(2)),nom(1:tmp),'FontSize',8,'Color','blue');
        end
    end
end
end
         

        
    