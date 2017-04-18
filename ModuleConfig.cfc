component {
	
	function configure() {
		
		settings = {
			downloadURL = 'https://intergral-dl.s3.amazonaws.com/FR/FusionReactor-6.2.8/fusionreactor.jar',
			jarPath = modulePath & '/FR-home/fusionreactor-6.2.8.jar',
			licenseKey = '',
			FRPort = '',
			enable = true
		};
				
	}
	
	function onServerStart( required struct interceptData ) {
		var consoleLogger = wirebox.getInstance( dsl='logbox:logger:console' );
		var serverService = wirebox.getInstance( 'ServerService' );
		var configService = wirebox.getInstance( 'ConfigService' );
		
		var serverInfo = arguments.interceptData.serverInfo;
		
		// read server.json
		var serverJSON = serverService.readServerJSON( serverInfo.serverConfigFile ?: '' );
		// Get defaults
		var defaults = configService.getSetting( 'server.defaults', {} );
		
		// Get all of our defaulted settings
		serverInfo.FRPort = serverJSON.fusionreactor.port ?: defaults.fusionreactor.port ?: settings.FRPort;
		serverInfo.FRlicenseKey = serverJSON.fusionreactor.licenseKey ?: defaults.fusionreactor.licenseKey ?: settings.licenseKey;
		serverInfo.FRDownloadURL = serverJSON.fusionreactor.downloadURL ?: defaults.fusionreactor.downloadURL ?: settings.downloadURL;
		serverInfo.FRJarPath = serverJSON.fusionreactor.jarPath ?: defaults.fusionreactor.jarPath ?: settings.jarPath;
		serverInfo.FREnable = serverJSON.fusionreactor.enable ?: defaults.fusionreactor.enable ?: settings.enable;
		
		// Returns false if downloading fails.
		if( serverInfo.FREnable && ensureJarExists( consoleLogger, serverInfo.FRJarPath, serverInfo.FRDownloadURL ) ) {
			
			consoleLogger.debug( '.' );
			consoleLogger.debug( '******************************************' );
			consoleLogger.debug( '* CommandBox FusionReactor Module Loaded *' ); 
			consoleLogger.debug( '******************************************' );
			consoleLogger.debug( '.' );
			
			var instanceJarpath = ( serverInfo.serverHomeDirectory ?: serverInfo.serverHome ?: serverInfo.webConfigDir & '/' & replace( serverInfo.cfengine, '@', '-' ) ) & '/fusionreactor/fusionreactor.jar';
			
			// Copy every time, so new versions get automatically used. 
			directoryCreate( getDirectoryFromPath( instanceJarpath ), true, true );
			fileCopy( serverInfo.FRJarPath, instanceJarpath );

			if( val( serverInfo.FRPort ) == 0 ) {
				serverInfo.FRPort = serverService.getRandomPort( serverInfo.host );
			}
						
			serverInfo.JVMArgs &= ' "-javaagent:#replaceNoCase( instanceJarpath, '\', '\\', 'all' )#=name=#serverInfo.name#,address=#serverInfo.FRPort#"';
			
			if( len( serverInfo.FRlicenseKey ) ) {
				serverInfo.JVMArgs &= ' -Dfrlicense=#serverInfo.FRlicenseKey#';
			}
			
			serverInfo.FRURL = 'http://#serverInfo.host#:#serverInfo.FRPort#';
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
	
	function ensureJarExists( consoleLogger, jarPath, downloadURL ) {
		
		if( !fileExists( arguments.jarPath ) ) {
			consoleLogger.warn( 'FusionReactor jar [#arguments.jarPath.listLast( "/" )#] not found.  Please wait for a moment while we download it.' );
			consoleLogger.warn( 'Downloading [#downloadURL#]' );
			
			var progressableDownloader = wirebox.getInstance( dsl='ProgressableDownloader');
			var progressBar = wirebox.getInstance( dsl='ProgressBar');
	
			try {
				progressableDownloader.download(
					downloadURL,
					arguments.jarPath,
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
				consoleLogger.warn( arguments.jarPath );
				consoleLogger.error( '.' );
				consoleLogger.debug( 'Continuing without FusionReactor.' );
				consoleLogger.debug( '.' );
				return false;
			}
			
		}
				
		return true;
		
	}
	
}