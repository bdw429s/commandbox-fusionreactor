component {

	function configure() {

		settings = {
			'installID' = 'fusionreactor@^2025.1.0',
			'debugEnable' = true,
			'licenseKey' = '',
			'hideLicenseKey' = false,
			'reactorConfFile' = '',
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
			'defaultApplicationName' = '',
			'autoApplicationNaming' = '',
			'serverName' = '',
			'externalServerEnable' = false,
			'EDSEnable' = false,
			'EDSListen' = '',
			'EDSPollTimeout' = '',
			'EDSMaxDataSize' = '',
			'EDSTarget' = '',
			'EDSGroups' = '',
			'ChatEnabled' = true
		};

	}

	function onServerStart( required struct interceptData ) {
		jobEnabled = wirebox.getBinder().mappingExists( 'interactiveJob' );


		consoleLogger = wirebox.getInstance( dsl='logbox:logger:console' );
		var serverService = wirebox.getInstance( 'ServerService' );
		var configService = wirebox.getInstance( 'ConfigService' );
		var systemSettings = wirebox.getInstance( 'SystemSettings' );
		var filesystemUtil = wirebox.getInstance( 'filesystem' );

		var serverInfo = arguments.interceptData.serverInfo;

		// Newer versions of CommandBox have this
		if( !isNull( interceptData.serverJSON ) ) {
			var serverJSON = interceptData.serverJSON;
		// Backwards compat for older versions
		} else {
			// read server.json
			var serverJSON = serverService.readServerJSON( serverInfo.serverConfigFile ?: '' );
			systemSettings.expandDeepSystemSettings( serverJSON );
		}

		// Get defaults
		var defaults = configService.getSetting( 'server.defaults', {} );
		systemSettings.expandDeepSystemSettings( defaults );

		serverInfo.FREnable = serverJSON.fusionreactor.enable ?: defaults.fusionreactor.enable ?: settings.enable;

		if( isBoolean( serverInfo.FREnable ) && serverInfo.FREnable ) {

			if( jobEnabled ) {
				var job = wirebox.getInstance( 'interactiveJob' );
				job.start( 'Loading FusionReactor' );
			}

			// Get all of our defaulted settings
			serverInfo.FRPort = serverJSON.fusionreactor.port ?: defaults.fusionreactor.port ?: serverInfo.FRPort ?: settings.FRPort;
			serverInfo.FRHost = serverJSON.fusionreactor.host ?: defaults.fusionreactor.host ?: serverJSON.web.host ?: defaults.web.host ?: serverInfo.host ?: settings.host;
			serverInfo.FRLicenseKey = serverJSON.fusionreactor.licenseKey ?: defaults.fusionreactor.licenseKey ?: settings.licenseKey;
			serverInfo.FRLicenseKeyHidden = serverJSON.fusionreactor.hideLicenseKey ?: defaults.fusionreactor.hideLicenseKey ?: settings.hideLicenseKey;
			serverInfo.FRInstallID = serverJSON.fusionreactor.installID ?: defaults.fusionreactor.installID ?: settings.installID;
			serverInfo.FRDebugEnable = serverJSON.fusionreactor.debugEnable ?: defaults.fusionreactor.debugEnable ?: settings.debugEnable;
			serverInfo.FRRESTRegisterURL = serverJSON.fusionreactor.RESTRegisterURL ?: defaults.fusionreactor.RESTRegisterURL ?: settings.RESTRegisterURL;
			serverInfo.FRRESTShutdownAction = serverJSON.fusionreactor.RESTShutdownAction ?: defaults.fusionreactor.RESTShutdownAction ?: settings.RESTShutdownAction;
			serverInfo.FRRESTRegisterHostname = serverJSON.fusionreactor.RESTRegisterHostname ?: defaults.fusionreactor.RESTRegisterHostname ?: settings.RESTRegisterHostname;
			serverInfo.FRRESTRegisterGroup = serverJSON.fusionreactor.RESTRegisterGroup ?: defaults.fusionreactor.RESTRegisterGroup ?: settings.RESTRegisterGroup;
			serverInfo.FRLicenseDeactivateOnShutdown = serverJSON.fusionreactor.licenseDeactivateOnShutdown ?: defaults.fusionreactor.licenseDeactivateOnShutdown ?: settings.licenseDeactivateOnShutdown;
			serverInfo.FRLicenseLeaseTimeout = serverJSON.fusionreactor.licenseLeaseTimeout ?: defaults.fusionreactor.licenseLeaseTimeout ?: settings.licenseLeaseTimeout;
			serverInfo.FRCloudGroup = serverJSON.fusionreactor.cloudGroup ?: defaults.fusionreactor.cloudGroup ?: settings.cloudGroup;
			serverInfo.FRRequestObfuscateParameters = serverJSON.fusionreactor.requestObfuscateParameters ?: defaults.fusionreactor.requestObfuscateParameters ?: settings.requestObfuscateParameters;
			serverInfo.FRDefaultApplicationName = serverJSON.fusionreactor.defaultApplicationName ?: defaults.fusionreactor.defaultApplicationName ?: serverInfo.name;
			serverInfo.FRAutoApplicationNaming = serverJSON.fusionreactor.autoApplicationNaming ?: defaults.fusionreactor.autoApplicationNaming ?: settings.autoApplicationNaming;
			serverInfo.FRServerName = serverJSON.fusionreactor.serverName ?: defaults.fusionreactor.serverName ?: settings.serverName;
			if( !len( serverInfo.FRServerName ) ) {
				serverInfo.FRServerName = serverInfo.name.replace( ' ', '', 'all' );
			}

			serverInfo.FRexternalServerEnable = serverJSON.fusionreactor.externalServerEnable ?: defaults.fusionreactor.externalServerEnable ?: settings.externalServerEnable;
			serverInfo.FREdDsEnable = serverJSON.fusionreactor.EDSEnable ?: defaults.fusionreactor.EDSEnable ?: settings.EDSEnable;
			serverInfo.FREdDsListen = serverJSON.fusionreactor.EDSListen ?: defaults.fusionreactor.EDSListen ?: settings.EDSListen;
			serverInfo.FREdDsPolltimeout = serverJSON.fusionreactor.EDSPollTimeout ?: defaults.fusionreactor.EDSPollTimeout ?: settings.EDSPollTimeout;
			serverInfo.FREdDsMaxdatasize = serverJSON.fusionreactor.EDSMaxDataSize ?: defaults.fusionreactor.EDSMaxDataSize ?: settings.EDSMaxDataSize;
			serverInfo.FREdDsTarget = serverJSON.fusionreactor.EDSTarget ?: defaults.fusionreactor.EDSTarget ?: settings.EDSTarget;
			serverInfo.FREdDsGroups = serverJSON.fusionreactor.EDSGroups ?: defaults.fusionreactor.EDSGroups ?: settings.EDSGroups;
			serverInfo.FRChatEnabled = serverJSON.fusionreactor.ChatEnabled ?: defaults.fusionreactor.ChatEnabled ?: settings.ChatEnabled;


			// Not putting this in serverInfo on purpose since it's potentially sensitive info
			var thisPassword = serverJSON.fusionreactor.password ?: defaults.fusionreactor.password ?: settings.password;

			serverInfo.FRHomeDirectory = serverInfo.serverHomeDirectory;
			if( !(  serverInfo.FRHomeDirectory.endsWith( '/' ) || serverInfo.FRHomeDirectory.endsWith( '\' ) ) ) {
				serverInfo.FRHomeDirectory &= '/';
			}
			serverInfo.FRHomeDirectory &= 'fusionreactor/';

			// Optimize installation for the default ForgeBox package
			var endpointService = wirebox.getInstance( 'endpointService' );
			var packageService = wirebox.getInstance( 'packageService' );
			var semanticVersion = wirebox.getInstance( 'semanticVersion@semver' );
			var endpointData = endpointService.resolveEndpoint( serverInfo.FRInstallID, 'fake' );
			var skipInstall = false;

			// Are we installing the "fusionreactor" endpoint from ForgeBox
			if( endpointData.endpointName == 'forgebox' && endpointData.endpoint.parseSlug( serverInfo.FRInstallID ) == 'fusionreactor'
				// the install directory exists and is already a package?  If not, assumptions do not apply
				&& directoryExists( serverInfo.FRHomeDirectory ) && packageService.isPackage( serverInfo.FRHomeDirectory ) ) {

				// Let's take a look at wehat's already installed, making a few assumptions about how this specific pakage is setup.
				var alreadyInstalledBoxJSON = packageService.readPackageDescriptor( serverInfo.FRHomeDirectory );

				// Is the package that is already installed fusionreactor?
				if( alreadyInstalledBoxJSON.slug == 'fusionreactor' ) {

					// Do we have a pinned version, and that is what is installed
					if( semanticVersion.isExactVersion( endpointData.endpoint.parseVersion( serverInfo.FRInstallID ) )
						&& !semanticVersion.isNew( alreadyInstalledBoxJSON.version, endpointData.endpoint.parseVersion( serverInfo.FRInstallID ) ) ) {

						logDebug( 'Pinned FusionReactor version [#alreadyInstalledBoxJSON.version#] is already installed, skipping installation.' );
						skipInstall = true;

					// We have a semver range, but FR has nothing newer
					} else {

						try {
							var updateData = endpointData.endpoint.getUpdate( 'fusionreactor', alreadyInstalledBoxJSON.version, true );
							if( !updateData.isOutdated ) {
								logDebug( 'Your FusionReactor version [#alreadyInstalledBoxJSON.version#] is already the latest, skipping installation.' );
								logDebug( 'Pin an exact FusionReactor version to skip this Forgebox check.' );
								skipInstall = true;
							}
						} catch( endpointException var e ) {
							logError( 'Error occurred while trying to check for updated ForgeBox version.' );
							logError( e.message & ' ' & e.detail );
						}
					}


				}
			}

			if( !skipInstall ) {
				// install FR jar and debug binaries
				packageService.installPackage( id=serverInfo.FRInstallID, directory=serverInfo.FRHomeDirectory, save=false, saveDev=false );
			}


			serverInfo.FRreactorConfFile = '';
			// If there is a reactorConfFile setting in server.json, resolve it realtive to the directory of the server.json file and use it
			if( !isNull( serverJSON.fusionreactor.reactorConfFile ) && len( serverJSON.fusionreactor.reactorConfFile ) ) {
				serverInfo.FRreactorConfFile = filesystemUtil.resolvePath( serverJSON.fusionreactor.reactorConfFile, getDirectoryFromPath( serverInfo.serverConfigFile ) );
			}

			// Next check for a global server default
			if( !len( serverInfo.FRreactorConfFile ) && !isNull( defaults.fusionreactor.reactorConfFile ) && len( defaults.fusionreactor.reactorConfFile ) ) {
				serverInfo.FRreactorConfFile = defaults.fusionreactor.reactorConfFile;
			}

			// Use the module default, in case we ever set one
			if( !len( serverInfo.FRreactorConfFile ) && len( settings.reactorConfFile ) ) {
				serverInfo.FRreactorConfFile = settings.reactorConfFile;
			}

			// if we have a reactor.conf file, copy it over so FR will use it.
			if( len( serverInfo.FRreactorConfFile ) ) {
				if( fileExists( serverInfo.FRreactorConfFile ) ) {
					logDebug( 'Copying FusionReactor config file: [#serverInfo.FRreactorConfFile#]' );
					directoryCreate( serverInfo.FRHomeDirectory & 'conf/', true, true );
					fileCopy( serverInfo.FRreactorConfFile, serverInfo.FRHomeDirectory & 'conf/reactor.conf' );
				} else {
					logError( 'The reactorConfFile setting of [#serverInfo.FRreactorConfFile#] does not exist on disk.'  );
				}
			}

			if( val( serverInfo.FRPort ) == 0 ) {
				serverInfo.FRPort = serverService.getRandomPort( serverInfo.host );
			}
			var address = serverInfo.FRPort;
			if( serverInfo.FRHost.len() ) {
				address =  serverInfo.FRHost & ':' & serverInfo.FRPort;
			}

			serverInfo.JVMArgs &= ' "-javaagent:#replaceNoCase( serverInfo.FRHomeDirectory, '\', '\\', 'all' )#fusionreactor.jar=name=#serverInfo.FRServerName#,address=#address#,external=#serverInfo.FRexternalServerEnable#"';

			if( len( serverInfo.FRlicenseKey ) ) { serverInfo.JVMArgs &= ' -Dfrlicense=#serverInfo.FRlicenseKey#'; }
			if( isBoolean( serverInfo.FRlicenseKeyHidden ) && serverInfo.FRlicenseKeyHidden ) { serverInfo.JVMArgs &= ' -Dfr.license.key.hidden=#serverInfo.FRlicenseKeyHidden#'; }
			if( len( thisPassword ) ) { serverInfo.JVMArgs &= ' "-Dfradminpassword=#thisPassword#"'; }
			if( len( serverInfo.FRRESTRegisterURL ) ) { serverInfo.JVMArgs &= ' "-Dfrregisterwith=#serverInfo.FRRESTRegisterURL#"'; }
			if( len( serverInfo.FRRESTShutdownAction ) ) { serverInfo.JVMArgs &= ' -Dfrshutdownaction=#serverInfo.FRRESTShutdownAction#'; }
			if( len( serverInfo.FRRESTRegisterHostname ) ) { serverInfo.JVMArgs &= ' -Dfrregisterhostname=#serverInfo.FRRESTRegisterHostname#'; }
			if( len( serverInfo.FRRESTRegisterGroup ) ) { serverInfo.JVMArgs &= ' -Dfrregistergroup=#serverInfo.FRRESTRegisterGroup#'; }
			if( len( serverInfo.FRLicenseDeactivateOnShutdown ) ) { serverInfo.JVMArgs &= ' -Dfrlicenseservice.deactivateOnShutdown=#serverInfo.FRLicenseDeactivateOnShutdown#'; }
			if( len( serverInfo.FRLicenseLeaseTimeout ) ) { serverInfo.JVMArgs &= ' -Dfrlicenseservice.leasetime.hint=#serverInfo.FRLicenseLeaseTimeout#'; }
			if( len( serverInfo.FRCloudGroup ) ) { serverInfo.JVMArgs &= ' "-Dfr.cloud.group=#serverInfo.FRCloudGroup#"'; }
			if( len( serverInfo.FRRequestObfuscateParameters ) ) { serverInfo.JVMArgs &= ' -Dfr.request.obfuscate.parameters=#serverInfo.FRRequestObfuscateParameters#'; }
			if( len( serverInfo.FRDefaultApplicationName ) ) { serverInfo.JVMArgs &= ' "-Dfr.application.name=#serverInfo.FRDefaultApplicationName#"'; }
			if( len( serverInfo.FRAutoApplicationNaming ) ) { serverInfo.JVMArgs &= ' -Dfr.application.auto_naming=#serverInfo.FRAutoApplicationNaming#'; }
			if( len( serverInfo.FREdDsEnable ) ) { serverInfo.JVMArgs &= ' -Dfr.ed.ds.enable=#serverInfo.FREdDsEnable#'; }
			if( len( serverInfo.FREdDsListen ) ) { serverInfo.JVMArgs &= ' -Dfr.ed.ds.listen=#serverInfo.FREdDsListen#'; }
			if( len( serverInfo.FREdDsPolltimeout ) ) { serverInfo.JVMArgs &= ' -Dfr.ed.ds.polltimeout=#serverInfo.FREdDsPolltimeout#'; }
			if( len( serverInfo.FREdDsMaxdatasize ) ) { serverInfo.JVMArgs &= ' -Dfr.ed.ds.maxdatasize=#serverInfo.FREdDsMaxdatasize#'; }
			if( len( serverInfo.FREdDsTarget ) ) { serverInfo.JVMArgs &= ' -Dfr.ed.ds.target=#serverInfo.FREdDsTarget#'; }
			if( len( serverInfo.FREdDsGroups ) ) { serverInfo.JVMArgs &= ' -Dfr.ed.ds.groups=#serverInfo.FREdDsGroups#'; }
			if( len( serverInfo.FRChatEnabled ) ) { serverInfo.JVMArgs &= ' -Dfr.chat.enabled=#serverInfo.FRChatEnabled#'; }

			// Optionally add the debug libs
			if( isBoolean( serverInfo.FRDebugEnable ) && serverInfo.FRDebugEnable ) {
				logDebug( 'FusionReactor debug libs added.' );
				var fileSystemUtil = wirebox.getInstance( 'fileSystem' );

				var isArm = ()=>systemSettings.getSystemSetting( 'os.arch', '' ).findNoCase( 'arm' ) || systemSettings.getSystemSetting( 'os.arch', '' ).findNoCase( 'aarch' );

				if( fileSystemUtil.isLinux() ) {
					var systemSettings = wirebox.getInstance( 'SystemSettings' );
					var LinuxARMDebuggerLibPath = serverInfo.FRHomeDirectory & '/libfrjvmti_aarch64.so';

					var debugLib = '';

					if( isArm() ) {
						if( fileExists( LinuxARMDebuggerLibPath ) ) {
							logDebug( 'Linux ARM detected for debug libs.' );
							debugLib = 'libfrjvmti_aarch64.so';
						} else {
							logDebug( 'Linux ARM detected, but no lib available.  Disabling FR debugger.' );
						}
					} else {
						logDebug( 'Linux detected for debug libs.' );
						debugLib = 'libfrjvmti_x64.so';
					}

				} else if( fileSystemUtil.isMac() ) {
					var MacARMDebuggerLibPath = serverInfo.FRHomeDirectory & '/libfrjvmti_arm64.dylib';

					if( isArm() ) {
						if( fileExists( MacARMDebuggerLibPath ) ) {
							logDebug( 'Mac ARM detected for debug libs.' );
							debugLib = 'libfrjvmti_arm64.dylib';
						} else {
							logDebug( 'Mac ARM detected, but no lib available.  Disabling FR debugger.' );
						}
					} else {
						logDebug( 'Mac detected for debug libs.' );
						debugLib = 'libfrjvmti_x64.dylib';
					}

				} else {
					logDebug( 'Windows detected for debug libs.' );
					debugLib = 'frjvmti_x64.dll';
				}

				if( len( debugLib ) ) {
					serverInfo.JVMArgs &= ' "-agentpath:#replaceNoCase( serverInfo.FRHomeDirectory, '\', '\\', 'all' )##debugLib#"';
				}

			}

			serverInfo.FRURL = 'http://#serverInfo.FRHost#:#serverInfo.FRPort#';
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

			if( jobEnabled ) {
	    		job.complete( interceptData.serverInfo.verbose ?: interceptData.serverInfo.debug );
			}

		}


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
