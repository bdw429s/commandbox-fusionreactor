/**
* Open the URL for the FusionReactor admin for this server 
* . 
* {code:bash}
* fusionreactor open 
* {code}
*/
component aliases='fr open' {
	// DI
	property name="serverService" inject="ServerService";
		
	/**
	 * @name.hint the short name of the server
	 * @name.optionsUDF serverNameComplete
	 * @directory.hint web root for the server
	 * @serverConfigFile The path to the server's JSON file.
	**/
	function run(
		string name,
		string directory,
		String serverConfigFile
		){
		if( !isNull( arguments.directory ) ) {
			arguments.directory = fileSystemUtil.resolvePath( arguments.directory );
		} 
		if( !isNull( arguments.serverConfigFile ) ) {
			arguments.serverConfigFile = fileSystemUtil.resolvePath( arguments.serverConfigFile );
		}		
		var serverDetails = serverService.resolveServerDetails( arguments );
		var serverInfo = serverDetails.serverInfo;
		 
		if( serverDetails.serverIsNew ){
			print.boldRedLine( "No server configurations found." );
		} else if( !serverInfo.keyExists( 'FRURL' ) ) {
			print.boldRedLine( "It looks like FusionReactor has never been started for this server." );
		} else {			
			var thisURL = "#serverInfo.FRURL#";
			print.greenLine( "Opening...#thisURL#" );
			openURL( thisURL );
		}
	}
	
	/**
	* Complete server names
	*/
	function serverNameComplete() {
		return serverService.getServerNames();
	}
		
}