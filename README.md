# Puppet Debugging Kit
_The only good bug is a dead bug._

This project provides a batteries-included Vagrant environment for debugging Puppet powered infrastructures.

## Setup

The dubugging kit can be used in two different configurations depending on the version of Vagrant installed on the user's machine.
If Vagrant 1.1+ or newer is in use system-wide, then setup merely consists of installing required Vagrant plugins.
If the system-wide version of Vagrant is 1.0.7 or earlier, the debugging kit provides a Bundler based sandbox that can be used to run a newer version of Vagrant that will not interfere with the legacy version installed on the system.

### Standard Setup

This is recommended for users who are running Vagrant 1.1 or newer.
Users with older Vagrant installs who do not wish to upgrade should consider the "Sandboxed Setup" detailed below.

A Rake task is provided which installs the necessary Vagrant plugins:

    rake setup:standard

### Sandboxed Setup

This option is provided for those users with a legacy Vagrant installation (1.0.7 or earlier) that needs to remain functional for other projects.

A Rake task is provided which sets up the bundler environment:

    rake setup:sandbox

The sandboxed version of vagrant can now be accessed through `bin/vagrant`.
I.E. to bring up a box, one would invoke `bin/vagrant up pe-301-master`.
The version of Vagrant operating out of the sandbox uses `/usr/local/var/vagrant/puppet-debugging-kit` as its `VAGRANT_HOME` to avoid clobbering legacy data in `~/.vagrant.d`.

#### Sandbox Customization

The sandbox can be customized through by creating a `Gemfile.local`.
Things that can be set inside this file include:

  - The `VAGRANT_HOME`, by assigning a value to `ENV['VAGRANT_HOME']`.

  - Additional gems, through the use of `gem` directives.

  - Additional Vagrant Plugins, by placing `gem` directives inside of a `group :vagrant_plugins do` block.

Full documentation for the contents of a Gemfile can be found on [the Bundler website](http://bundler.io/v1.3/gemfile.html).

---
<p align="center">
  <img src="http://i.imgur.com/TFTT0Jh.png" />
</p>
