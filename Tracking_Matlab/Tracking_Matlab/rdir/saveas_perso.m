function saveas_perso(fig,varargin)
    set(fig,'visible','on');
    set(fig,'renderer','painters'); % make editable figure when saving as pdf.
    drawnow;
    saveas(fig,varargin{:});
end