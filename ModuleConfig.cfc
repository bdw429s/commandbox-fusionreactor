component {
	
	function configure() {
		
		settings = {
			downloadURL = 'https://intergral-dl.s3.amazonaws.com/FR/FusionReactor-6.2.5/fusionreactor.jar',
			jarPath = modulePath & '/FR-home/fusionreactor.jar',
			licenseKey = ''
		};
				
	}
	
	function onServerStart( required struct interceptData ) {
		var serverInfo = arguments.interceptData.serverInfo;
		var consoleLogger = wirebox.getInstance( dsl='logbox:logger:console' );
		var serverService = wirebox.getInstance( 'ServerService' );
		
		consoleLogger.debug( '.' );
		consoleLogger.debug( '******************************************' );
		consoleLogger.debug( '* CommandBox FusionReactor Module Loaded *' ); 
		consoleLogger.debug( '******************************************' );
		consoleLogger.debug( '.' );
		
		// Returns false if downloading fails.
		if( ensureJarExists( consoleLogger ) ) {
			var instanceJarpath = ( serverInfo.serverHomeDirectory ?: serverInfo.serverHome ?: serverInfo.webConfigDir & '/' & replace( serverInfo.cfengine, '@', '-' ) ) & '/fusionreactor/fusionreactor.jar';
			if( !fileExists( instanceJarpath ) ) {
				directoryCreate( getDirectoryFromPath( instanceJarpath ), true, true );
				fileCopy( settings.jarPath, instanceJarpath );
			}
		
			var FRPort = serverService.getRandomPort( serverInfo.host );
						
			serverInfo.JVMArgs &= ' -javaagent:"#replaceNoCase( instanceJarpath, '\', '\\', 'all' )#=name=#serverInfo.name#,address=#FRPort#"';
			
			if( len( settings.licenseKey ) ) {
				serverInfo.JVMArgs &= ' -Dfrlicense=#settings.licenseKey#';
			}
			
			serverInfo.FRURL = 'http://#serverInfo.host#:#FRPort#';
			consoleLogger.debug( 'FusionReactor will be available at the URL #serverInfo.FRURL#' );
			consoleLogger.debug( '.' );
			
			// Check for older version of CommandBox
			if( serverInfo.keyExists( 'trayOptions' ) ) {
				// Add FusionReactor menu item to tray icon.
		    	serverInfo.trayOptions.append(
					[
						{ 'label':'Open FusionReactor', 'action':'openbrowser', 'url':serverInfo.FRURL, 'image':'#modulePath#/fusion_reactor.png' }
					],
					true
				);		
			}
			
		}
		
	}
	
	function ensureJarExists( consoleLogger ) {
		
		if( !fileExists( settings.jarPath ) ) {
			consoleLogger.warn( 'FusionReactor jar not found.  Please wait for a moment while we download it.' );
			consoleLogger.warn( 'Downloading [#settings.downloadURL#]' );
			
			var progressableDownloader = wirebox.getInstance( dsl='ProgressableDownloader');
			var progressBar = wirebox.getInstance( dsl='ProgressBar');
	
			try {
				progressableDownloader.download(
					settings.downloadURL,
					settings.jarPath,
					function( status ) {
						progressBar.update( argumentCollection = status );
					}
				);
							
				consoleLogger.warn( 'Done, you''re all set!' );
								
			} catch( Any var e ) {
				consoleLogger.error( 'We''ve run into an issue downloading FusionReactor!' );
				consoleLogger.error( '#e.message##chr( 10 )##e.detail#' );
				consoleLogger.error( '.' );
				consoleLogger.warn( 'If you don''t have an internet connection, please manually place the file here:' );
				consoleLogger.warn( settings.jarPath );
				consoleLogger.error( '.' );
				consoleLogger.debug( 'Continuing without FusionReactor.' );
				consoleLogger.debug( '.' );
				return false;
			}
			
		}
				
		return true;
		
	}
	
}