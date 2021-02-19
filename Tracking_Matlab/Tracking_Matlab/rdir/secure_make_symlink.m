function secure_make_symlink(basebasepath_,pbasepath,basepath__)
% curdir,target,linkname
    st = system(['cd "' basebasepath_ '" && if ! test -L "' pbasepath ...
        '" && ! test -d "' pbasepath '" ; then ln -s ./"' basepath__ '" "' pbasepath '" ; else exit 10; fi']);
    if st==0
        info_perso(['create symlink to the previous project dir ( "' basepath__ '" --> "' pbasepath '")']);
    else
        info_perso(['NOT created symlink to the previous project dir ( "' basepath__ '" --> "' pbasepath '", a link or a dir already exist ?)']);
    end
end