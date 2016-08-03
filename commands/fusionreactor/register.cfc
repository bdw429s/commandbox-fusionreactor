/**
* Register an existing license key with the FusionReactor module.  This licence key will be used on future server starts.
* . 
* {code:bash}
* fusionreactor register XXXXX-XXXXX-XXXXX-XXXXX-XXXXX 
* {code}
*/
component aliases='fr register,fr license' {
	property name='ConfigService' inject='ConfigService';
	
	/**
	* licenseKey The license key to activate your FusionReactor instance with
	 */
	function run( required string licenseKey ) {
		// Get the config settings
		var configSettings = ConfigService.getconfigSettings();
		
		// Set the setting
		configSettings[ 'modules' ][ 'commandbox-fusionreactor' ][ 'licenseKey' ]=arguments.licenseKey;
 
		// Save the setting struct
		ConfigService.setConfigSettings( configSettings );
				
		print.greenBoldLine( 'FusionReactor activated.' );
	}
	
}