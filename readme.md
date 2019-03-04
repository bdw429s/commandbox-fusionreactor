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


For full docs on this module, go here:

https://commandbox.ortusbooks.com/embedded-server/fusionreactor
