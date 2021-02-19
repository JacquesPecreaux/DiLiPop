function init_movie2(name,arg)
global param;
    if isfield(param,'no_java') && ~isempty(param.no_java) && param.no_java
        return 
    end
nom=sprintf('%s.mov',name);
MakeQTMovie('start',nom);
MakeQTMovie('framerate',15);    

orig_mode=get(arg,'PaperPositionMode');
set(arg,'PaperPositionMode','auto');
drawnow_perso;
% I=hardcopy(arg,'-Dzbuffer','-r0');
figure(arg);
I=print('-RGBImage');
set(arg,'PaperPositionMode',orig_mode);

MakeQTMovie('size',[size(I,2) size(I,1)]);
MakeQTMovie('quality',0.9);

end