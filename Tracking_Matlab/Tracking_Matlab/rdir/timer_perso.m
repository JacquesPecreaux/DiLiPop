classdef timer_perso < timer
    properties
        working_folder_orig
    end
    methods
        function h=timer_perso(wfo,varargin)
            h@timer(varargin{:});
            h.working_folder_orig=wfo;
        end
        function delete(h)
            disp('Deleting timer_perso');
            working_dir_move(working_folder_orig);
            delete@timer(h);
        end
    end
end