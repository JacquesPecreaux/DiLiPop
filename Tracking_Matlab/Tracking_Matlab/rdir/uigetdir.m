function ret = uigetdir(varargin)
    import javax.swing.JFileChooser;
    ret=[];
    if nargin<1
        path=pwd;
    else
        path=varargin{1};
    end
    if nargin<2
        tit='Please choose a directory';
    else
        tit=varargin{2};
    end
    hFig = dialog('Name',tit,'windowstyle', 'normal', 'position', [0 0 750 400]);
    [jPanel,hPanel] = javacomponent(javax.swing.JPanel, [], hFig);
    set(hPanel, 'units','normalized','position',[0 0 0.9 1.0]);
    fc = javaObjectEDT('javax.swing.JFileChooser',path);
    fc.setDialogType(javax.swing.JFileChooser.OPEN_DIALOG)
%     fc.setCurrentDirectory(javaObject('java.io.File',path));
    fc.setFileSelectionMode(javax.swing.JFileChooser.DIRECTORIES_ONLY);
%     fc.setDialogTitle(javaObject('java.lang.String',tit));
    set(handle(fc, 'callbackproperties'),'ActionPerformedCallback', @callback);
    jPanel.add(fc);
    waitfor(hFig);
    
    function callback(hObj,evt)
       if evt.getActionCommand == javax.swing.JFileChooser.APPROVE_SELECTION
               ret = char(fc.getSelectedFile().getCanonicalPath());
               close(hFig);
       else %javax.swing.JFileChooser.CANCEL_SELECTION
               ret =[] ; 
               close(hFig);
       end
    end
    
end