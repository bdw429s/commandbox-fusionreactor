[![Master Branch Build Status](https://img.shields.io/travis/bdw429s/commandbox-fusionreactor/master.svg?style=flat-square&label=master)](https://travis-ci.org/bdw429s/commandbox-fusionreactor)

This module adds support to enable FusionReactor on the servers you start inside CommandBox.  

For full docs on this module, go here:
https://commandbox.ortusbooks.com/embedded-server/fusionreactor

For an overview of common settings and usage, read below.

## Installation

Install the module like so:

```bash
install commandbox-fusionreactor
```

# Configuration

This will automatically add the JVM args into any server you start using the `server start` command.

Add your FusionReactor license like so:

```bash
fusionreactor register "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
```

You can get a FusionReactor trial, or if you need to purchase a license, visit here:
[https://www.ortussolutions.com/products/fusion-reactor](https://www.ortussolutions.com/products/fusion-reactor)

## Usage

FusionReactor will choose a random, unused port to bind to.  Check the console when starting the server to see what it is.

You can open the FusionReactor web admin by running the following command:

```bash
fusionreactor open
```

# Additional Configuration

You can override the default settings for a single server with the following properties in your server's `server.json`.

```bash
# Disable the module
server set fusionreactor.enable=false
# Set a custom port
server set fusionreactor.port=8088
# set your license key
server set fusionreactor.licenseKey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
# Override the jar download to a custom URL of your choice
server set fusionreactor.downloadURL=http://site.com/custom/path/fusionreactor.jar
# Where the jar downloads to internally. Change this to force a new download
server set fusionreactor.jarPath=/FR-home/fusionreactor-custom.jar
```

You can configure the defaults for all servers in the Config Setting server defaults.

```bash
config set server.defaults.fusionreactor.enable=false
config set server.defaults.fusionreactor.port=8088
config set server.defaults.fusionreactor.licenseKey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
config set server.defaults.fusionreactor.downloadURL=http://site.com/custom/path/fusionreactor.jar
config set server.defaults.fusionreactor.jarPath=/FR-home/fusionreactor-custom.jar
```

Changing the module's core settings will also apply to all servers.

```bash
config set modules.commandbox-fusionreactor.enable=false
config set modules.commandbox-fusionreactor.port=8088
config set modules.commandbox-fusionreactor.licenseKey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
config set modules.commandbox-fusionreactor.downloadURL=http://site.com/custom/path/fusionreactor.jar
config set modules.commandbox-fusionreactor.jarPath=/FR-home/fusionreactor-custom.jar
```

Settings are used in this order:
1) The `server.json` for the server you're starting
2) The server defaults in your Config Settings
3) The module default settings in your Config Settings
4) The hard-coded defaults in the module's code
