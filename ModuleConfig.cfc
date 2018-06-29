component {
	
	function configure() {
		
		settings = {
			// https://intergral-dl.s3.amazonaws.com/FR/FusionReactor-7.0.4/debuglibs-7.0.4.zip
			'downloadURL' = 'https://intergral-dl.s3.amazonaws.com/FR/FusionReactor-{version}/fusionreactor.jar',
			'jarPath' = modulePath & '/FR-home/fusionreactor-{version}.jar',
			'version' = '7.2.4',
			'licenseKey' = '',
			'FRPort' = '',
			'FRHost' = '',
			'password' = '',
			'enable' = true,
			'RESTRegisterURL' = '',
			'RESTShutdownAction' = '',
			'RESTRegisterHostname' = '',
			'RESTRegisterGroup' = '',
			'licenseDeactivateOnShutdown' = '',
			'licenseLeaseTimeout' = '',
			'cloudGroup' = '',
			'requestObfuscateParameters' = '',
			'defaultApplicationName' = ''
		};
		
	}
	
	function onServerStart( required struct interceptData ) {
		jobEnabled = wirebox.getBinder().mappingExists( 'interactiveJob' );		
		consoleLogger = wirebox.getInstance( dsl='logbox:logger:console' );
		var serverService = wirebox.getInstance( 'ServerService' );
		var configService = wirebox.getInstance( 'ConfigService' );
		var systemSettings = wirebox.getInstance( 'SystemSettings' );
		
		var serverInfo = arguments.interceptData.serverInfo;
		
		// read server.json
		var serverJSON = serverService.readServerJSON( serverInfo.serverConfigFile ?: '' );
		// Get defaults
		var defaults = configService.getSetting( 'server.defaults', {} );
		
		systemSettings.expandDeepSystemSettings( serverJSON );
		systemSettings.expandDeepSystemSettings( defaults );
		
		// Get all of our defaulted settings
		serverInfo.FRPort = serverJSON.fusionreactor.port ?: defaults.fusionreactor.port ?: serverInfo.FRPort ?: settings.FRPort;
		serverInfo.FRHost = serverJSON.web.host ?: defaults.web.host ?: serverInfo.host ?: settings.host;
		serverInfo.FRLicenseKey = serverJSON.fusionreactor.licenseKey ?: defaults.fusionreactor.licenseKey ?: settings.licenseKey;
		serverInfo.FRDownloadURL = serverJSON.fusionreactor.downloadURL ?: defaults.fusionreactor.downloadURL ?: settings.downloadURL;
		serverInfo.FRJarPath = serverJSON.fusionreactor.jarPath ?: defaults.fusionreactor.jarPath ?: settings.jarPath;
		serverInfo.FREnable = serverJSON.fusionreactor.enable ?: defaults.fusionreactor.enable ?: settings.enable;
		serverInfo.FRVersion = serverJSON.fusionreactor.version ?: defaults.fusionreactor.version ?: settings.version;
		// Not putting this in serverInfo on purpose since it's potentially sensitive info
		var thisPassword = serverJSON.fusionreactor.password ?: defaults.fusionreactor.password ?: settings.password;
		
		
		serverInfo.FRRESTRegisterURL = serverJSON.fusionreactor.RESTRegisterURL ?: defaults.fusionreactor.RESTRegisterURL ?: settings.RESTRegisterURL;
		serverInfo.FRRESTShutdownAction = serverJSON.fusionreactor.RESTShutdownAction ?: defaults.fusionreactor.RESTShutdownAction ?: settings.RESTShutdownAction;
		serverInfo.FRRESTRegisterHostname = serverJSON.fusionreactor.RESTRegisterHostname ?: defaults.fusionreactor.RESTRegisterHostname ?: settings.RESTRegisterHostname;
		serverInfo.FRRESTRegisterGroup = serverJSON.fusionreactor.RESTRegisterGroup ?: defaults.fusionreactor.RESTRegisterGroup ?: settings.RESTRegisterGroup;
		serverInfo.FRLicenseDeactivateOnShutdown = serverJSON.fusionreactor.licenseDeactivateOnShutdown ?: defaults.fusionreactor.licenseDeactivateOnShutdown ?: settings.licenseDeactivateOnShutdown;
		serverInfo.FRLicenseLeaseTimeout = serverJSON.fusionreactor.licenseLeaseTimeout ?: defaults.fusionreactor.licenseLeaseTimeout ?: settings.licenseLeaseTimeout;
		serverInfo.FRCloudGroup = serverJSON.fusionreactor.cloudGroup ?: defaults.fusionreactor.cloudGroup ?: settings.cloudGroup;
		serverInfo.FRRequestObfuscateParameters = serverJSON.fusionreactor.requestObfuscateParameters ?: defaults.fusionreactor.requestObfuscateParameters ?: settings.requestObfuscateParameters;
		serverInfo.FRDefaultApplicationName = serverJSON.fusionreactor.defaultApplicationName ?: defaults.fusionreactor.defaultApplicationName ?: serverInfo.name;
		
		
		
		// Swap out version placeholders, if they exist.
		serverInfo.FRJarPath = serverInfo.FRJarPath.replaceNoCase( '{version}', serverInfo.FRVersion );
		serverInfo.FRDownloadURL = serverInfo.FRDownloadURL.replaceNoCase( '{version}', serverInfo.FRVersion ); 
		
		// Returns false if downloading fails.
		if( serverInfo.FREnable && ensureJarExists( serverInfo.FRJarPath, serverInfo.FRDownloadURL ) ) {
			
			logDebug( '.' );
			logDebug( '******************************************' );
			logDebug( '* CommandBox FusionReactor Module Loaded *' ); 
			logDebug( '******************************************' );
			logDebug( '.' );
			
			var instanceJarpath = ( serverInfo.serverHomeDirectory ?: serverInfo.serverHome ?: serverInfo.webConfigDir & '/' & replace( serverInfo.cfengine, '@', '-' ) ) & '/fusionreactor/fusionreactor.jar';
			
			// Copy every time, so new versions get automatically used. 
			directoryCreate( getDirectoryFromPath( instanceJarpath ), true, true );
			fileCopy( serverInfo.FRJarPath, instanceJarpath );

			if( val( serverInfo.FRPort ) == 0 ) {
				serverInfo.FRPort = serverService.getRandomPort( serverInfo.host );
			}
			var address = serverInfo.FRPort;
			if( serverInfo.FRHost.len() ) {
				address =  serverInfo.FRHost & ':' & serverInfo.FRPort;
			}
						
			serverInfo.JVMArgs &= ' "-javaagent:#replaceNoCase( instanceJarpath, '\', '\\', 'all' )#=name=#serverInfo.name#,address=#address#"';
			
			if( len( serverInfo.FRlicenseKey ) ) { serverInfo.JVMArgs &= ' -Dfrlicense=#serverInfo.FRlicenseKey#'; }
			if( len( thisPassword ) ) { serverInfo.JVMArgs &= ' -Dfradminpassword=#thisPassword#'; }
			if( len( serverInfo.FRRESTRegisterURL ) ) { serverInfo.JVMArgs &= ' -Dfrregisterwith=#serverInfo.FRRESTRegisterURL#'; }
			if( len( serverInfo.FRRESTShutdownAction ) ) { serverInfo.JVMArgs &= ' -Dfrshutdownaction=#serverInfo.FRRESTShutdownAction#'; }
			if( len( serverInfo.FRRESTRegisterHostname ) ) { serverInfo.JVMArgs &= ' -Dfrregisterhostname=#serverInfo.FRRESTRegisterHostname#'; }
			if( len( serverInfo.FRRESTRegisterGroup ) ) { serverInfo.JVMArgs &= ' -Dfrregistergroup=#serverInfo.FRRESTRegisterGroup#'; }
			if( len( serverInfo.FRLicenseDeactivateOnShutdown ) ) { serverInfo.JVMArgs &= ' -Dfrlicenseservice.deactivateOnShutdown=#serverInfo.FRLicenseDeactivateOnShutdown#'; }
			if( len( serverInfo.FRLicenseLeaseTimeout ) ) { serverInfo.JVMArgs &= ' -Dfrlicenseservice.leasetime.hint=#serverInfo.FRLicenseLeaseTimeout#'; }
			if( len( serverInfo.FRCloudGroup ) ) { serverInfo.JVMArgs &= ' -Dfr.cloud.group=#serverInfo.FRCloudGroup#'; }
			if( len( serverInfo.FRRequestObfuscateParameters ) ) { serverInfo.JVMArgs &= ' -Dfr.request.obfuscate.parameters=#serverInfo.FRRequestObfuscateParameters#'; }
			if( len( serverInfo.FRDefaultApplicationName ) ) { serverInfo.JVMArgs &= ' -Dfr.application.name=#serverInfo.FRDefaultApplicationName#'; }
			
			serverInfo.FRURL = 'http://#serverInfo.host#:#serverInfo.FRPort#';
			logDebug( 'FusionReactor will be available at the URL #serverInfo.FRURL#' );
			logDebug( '.' );
			
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
	
	function ensureJarExists( jarPath, downloadURL ) {
		
		if( !fileExists( arguments.jarPath ) ) {
			logWarn( 'FusionReactor jar [#arguments.jarPath.listLast( "/" )#] not found.  Please wait for a moment while we download it.' );
			logWarn( 'Downloading [#downloadURL#]' );
			
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
							
				logWarn( 'Done, you''re all set!' );
								
			} catch( Any var e ) {
				consoleLogger.error( 'We''ve run into an issue downloading FusionReactor!' );
				logError( '#e.message##chr( 10 )##e.detail#' );
				logError( '.' );
				logWarn( 'If you don''t have an internet connection, please manually place the file here:' );
				logWarn( arguments.jarPath );
				logError( '.' );
				logDebug( 'Continuing without FusionReactor.' );
				logDebug( '.' );
				return false;
			}
			
		}
				
		return true;
		
	}
	
	private function logError( message ) {
		if( jobEnabled ) {
			if( message == '.' ) { return; }
			var job = wirebox.getInstance( 'interactiveJob' );
			job.addErrorLog( message );
		} else {
			consoleLogger.error( message );
		}
	}
	
	private function logWarn( message ) {
		if( jobEnabled ) {
			if( message == '.' ) { return; }
			var job = wirebox.getInstance( 'interactiveJob' );
			job.addWarnLog( message );
		} else {
			consoleLogger.warn( message );
		}
	}
	
	private function logDebug( message ) {
		if( jobEnabled ) {
			if( message == '.' ) { return; }
			var job = wirebox.getInstance( 'interactiveJob' );
			job.addLog( message );
		} else {
			consoleLogger.debug( message );
		}
	}
	
}
