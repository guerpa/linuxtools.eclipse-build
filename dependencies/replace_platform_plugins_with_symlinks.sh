# This script replaces all plugins in platform that can be replaced with symlinks
# It goes into a folder that is first argument of the script
# Then into plugins, and then symlinks 


function _symlink {
	_f=`ls | grep -e "^$1"`; \
	rm -rf ${_f} ; \
	ln -s /usr/share/java/$2 ${_f} 
}
pushd $1
	#symlink what should be symlinked
	pushd plugins
	
	#So, remove duplicated jars and symlink them
		_symlink com.ibm.icu_ icu4j-eclipse/plugins/com.ibm.icu_*.jar
		_symlink com.jcraft.jsch_ jsch.jar 
		_symlink javax.el_ tomcat-el-api.jar
		_symlink javax.xml_ xml-commons-apis.jar
		_symlink javax.inject_ atinject.jar
		_symlink javax.servlet_ tomcat-servlet-api.jar
		_symlink javax.servlet.jsp_ glassfish-jsp-api.jar
		_symlink org.apache.batik.css_ batik/batik-css.jar
		_symlink org.apache.batik.util_ batik/batik-util.jar
		_symlink org.apache.batik.util.gui_ batik/batik-gui-util.jar
		_symlink org.apache.commons.codec_ commons-codec.jar
		_symlink org.apache.commons.httpclient_ commons-httpclient.jar
		_symlink org.apache.commons.logging_ commons-logging.jar
		_symlink org.apache.felix.gogo.command_ felix/org.apache.felix.gogo.command.jar
		_symlink org.apache.felix.gogo.runtime_ felix/org.apache.felix.gogo.runtime.jar
		_symlink org.apache.felix.gogo.shell_ felix/org.apache.felix.gogo.shell.jar
		_symlink org.apache.geronimo.specs.geronimo-annotation_1.1_spec_ geronimo-annotation.jar
		_symlink org.apache.lucene.core_ lucene.jar
		_symlink org.apache.lucene.analysis_ lucene-contrib/lucene-analyzers.jar
		_symlink org.eclipse.ecf_ ecf/eclipse/plugins/org.eclipse.ecf_*.jar
		_symlink org.eclipse.ecf.identity_ ecf/eclipse/plugins/org.eclipse.ecf.identity_*.jar
		_symlink org.eclipse.ecf.filetransfer_ ecf/eclipse/plugins/org.eclipse.ecf.filetransfer_*.jar
		_symlink org.eclipse.ecf.provider.filetransfer.httpclient_ ecf/eclipse/plugins/org.eclipse.ecf.provider.filetransfer.httpclient_*.jar
		_symlink org.eclipse.ecf.provider.filetransfer.httpclient.ssl_ ecf/eclipse/plugins/org.eclipse.ecf.provider.filetransfer.httpclient.ssl_*.jar
		_symlink org.eclipse.ecf.provider.filetransfer.ssl_ ecf/eclipse/plugins/org.eclipse.ecf.provider.filetransfer.ssl_*.jar
		_symlink org.eclipse.ecf.provider.filetransfer_ ecf/eclipse/plugins/org.eclipse.ecf.provider.filetransfer_*.jar
		_symlink org.eclipse.ecf.ssl_ ecf/eclipse/plugins/org.eclipse.ecf.ssl_*.jar
		_symlink org.eclipse.emf.common_ emf/eclipse/plugins/org.eclipse.emf.common_*.jar
		_symlink org.eclipse.emf.ecore.change_ emf/eclipse/plugins/org.eclipse.emf.ecore.change_*.jar
		_symlink org.eclipse.emf.ecore_ emf/eclipse/plugins/org.eclipse.emf.ecore_*.jar
		_symlink org.eclipse.emf.ecore.xmi_ emf/eclipse/plugins/org.eclipse.emf.ecore.xmi_*.jar
		_symlink org.eclipse.jetty.util_ jetty/jetty-util.jar
		_symlink org.eclipse.jetty.server_ jetty/jetty-server.jar
		_symlink org.eclipse.jetty.http_ jetty/jetty-http.jar
		_symlink org.eclipse.jetty.continuation_ jetty/jetty-continuation.jar
		_symlink org.eclipse.jetty.io_ jetty/jetty-io.jar
		_symlink org.eclipse.jetty.security_ jetty/jetty-security.jar
		_symlink org.eclipse.jetty.servlet_ jetty/jetty-servlet.jar
		_symlink org.glassfish.web.javax.servlet.jsp_ glassfish-jsp.jar
		_symlink org.sat4j.core_ org.sat4j.core.jar
		_symlink org.sat4j.pb_ org.sat4j.pb.jar
		_symlink org.w3c.css.sac_ sac.jar
		_symlink org.w3c.dom.svg_ xml-commons-apis-ext.jar
	popd
popd