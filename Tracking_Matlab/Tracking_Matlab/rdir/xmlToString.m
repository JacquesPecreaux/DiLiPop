function str = xmlToString(xml)
    sw = javaObject('java.io.StringWriter');
    try
        tr = javax.xml.transform.TransformerFactory.newInstance().newTransformer();
		tr.setOutputProperty(javax.xml.transform.OutputKeys.INDENT, 'yes');
		tr.setOutputProperty(javax.xml.transform.OutputKeys.METHOD,'xml');
		tr.setOutputProperty('{http://xml.apache.org/xslt}indent-amount', '3');
		sr = javaObject('javax.xml.transform.stream.StreamResult',sw);
		tr.transform( javaObject('javax.xml.transform.dom.DOMSource',xml),sr);
        str = char(javaObject('java.lang.String',sw.getBuffer()));
        return
    catch error_
            reporter(nan,error_,mfilename);
            warning_perso('Catch error in saving segmentation \n\terror # %s : %s\n%s\n',error_.identifier,strrep(error_.message,sprintf('\n'),sprintf('\n\t')),stack_text(error_.stack));
    end
    str = 'error';
end