# Puppet Debugging Kit
_The only good bug is a dead bug._

This project provides a batteries-included Vagrant environment for debugging Puppet powered infrastructures.

#### Table of Contents


<!-- vim-markdown-toc GFM -->
* [Setup](#setup)
  * [Install Vagrant Plugins](#install-vagrant-plugins)
  * [Create VM Definitions](#create-vm-definitions)
  * [Clone Puppet Open Source Projects](#clone-puppet-open-source-projects)
* [Usage](#usage)
  * [Roles](#roles)
    * [General-Purpose Roles](#general-purpose-roles)
    * [PE-Specific Roles](#pe-specific-roles)
    * [POSS-Specific Roles](#poss-specific-roles)
  * [Bolt Based Provisioning](#bolt-based-provisioning)
* [Extending and Contributing](#extending-and-contributing)

<!-- vim-markdown-toc -->

## Setup

Getting the debugging kit ready for use consists of three steps:

  1. Ensure the proper [Vagrant plugins are installed](#install-vagrant-plugins).

  2. [Create VM definitions](#create-vm-definitions) in `config/vms.yaml`.

  3. [Clone Puppet Open Source projects](#clone-puppet-open-source-projects) to
     `src/puppetlabs` _(optional)_.

  4. [Install Bolt](https://puppet.com/docs/bolt/latest/bolt_installing.html) to
      enable bolt provisioning _(optional)_.

Rake tasks and templates are provided to help with all three steps.

### Install Vagrant Plugins

Two methods are available depending on whether a global Vagrant installation,
such as provided by the official packages from
[vagrantup.com](http://vagrantup.com), is in use:

  - <a id="rake setup:global" /> **`rake setup:global`**:
    This Rake task will add all plugins required by the debugging kit to
    a global Vagrant installation.

  - <a id="rake setup:sandboxed" /> **`rake setup:sandboxed`**:
    This Rake task will use Bundler to create a completely sandboxed Vagrant
    installation that includes the plugins required by the debugging kit.
    The contents of the sandbox can be customized by creating a `Gemfile.local`
    that specifies additional gems and Bundler environment parameters.

### Create VM Definitions

Debugging Kit virtual machine definitions are stored in the file
`config/vms.yaml` and an example is provided as
[`config/vms.yaml.example`][vms_yaml_example].
The example can simply be copied to `config/vms.yaml`, but it contains a large
number of VM definitions which adds some notable lag to Vagrant start-up times.
Start-up lag can be remedied by pruning unwanted definitions after copying the
example file.


### Clone Puppet Open Source Projects

The [`poss-envpuppet` role](#poss-envpuppet) is designed to run Puppet in guest
machines directly from Git clones located on the host machine at
`src/puppetlabs/`. This role is useful for inspecting and debugging changes in
behavior between versions without re-installing packages.

The required Git clones can be created by running the following Rake task:

    rake setup:poss


## Usage

Use of the debugging kit consists of:

  - Creating a new VM definition in `config/vms.yaml`.
    - The `box:` component determines which Vagrant basebox will be used.

  - Assigning a list of ["roles"](#roles) that customize the VM behavior.
    - The role list can be viewed as a stack―the last entry is applied first.
    - Most VMs start with the [`base`](#base) role which
      auto-assigns an IP address and sets up network connectivity.
    - The default roles can be found in
      [`data/puppet_debugging_kit/roles.yaml`][roles_yaml], and are explained
      in more detail below.
  - Optionally using ["bolt based provisioning"](#bolt-based-provisioning)
    - Building roles to call Bolt modules.
    - Roles can contain triggers or provisioners to initiate plans, tasks, or commands.
    - An example set are found in `config/bolt_vms.yaml.example`.
    - An example Puppetfile is found in `Puppetfile.example`.


### Roles


#### General-Purpose Roles

  - <a id="base" /> **`base`**: Auto-assigns an IP address and sets up network
  - <a id="windows" /> **`windows`**: Sets `winrm` as the communicator and
    port-forwards SSH and RDP
  - <a id="el-stop-firewall" /> **`el-stop-firewall`**: Stops `iptables`
    (<=EL6) or `firewalld` (>=EL7)
  - <a id="el-fix-path" /> **`el-fix-path`**: Adds `/usr/local/bin` to `$PATH`
  - <a id="el-6-epel" />   **`el-6-epel`**:   Adds EPEL repos to EL6
  - <a id="1gb-memory" />  **`1gb-memory`**:  VM uses 1GB RAM
  - <a id="2gb-memory" />  **`2gb-memory`**:  VM uses 2GB RAM
  - <a id="4gb-memory" />  **`4gb-memory`**:  VM uses 4GB RAM
  - <a id="small-size" />  **`small-size`**:  equivalent to `1gb-memory`
  - <a id="large-size" />  **`large-size`**:  equivalent to `4gb-memory`


#### PE-Specific Roles

Several roles are available to assist with creating PE machines:

  - <a id="pe-forward-console" /> **`pe-forward-console`**:
    Sets up a port forward for console access from 443 on the guest VM to 4443
    on the host machine.
    If some other running VM is already forwarding to 4443 on the host, Vagrant
    will choose a random port number that will be displayed in the log output
    when the VM starts up.

  - <a id="pe-<version>-master" /> **`pe-<version>-master`**:
    Performs an all-in-one master installation of PE `<version>` on the guest
    VM.
    - When specifying the version number, remove any separators such that
      `3.2.1` becomes `321`.
    - The PE console is configured with username `admin@puppetlabs.com` and
      password `puppetlabs`.

  - <a id="pe-<version>-agent" /> **`pe-<version>-agent`**:
    This role performs an agent installation of PE `<version>` on the guest VM.
    The agent is configured to contact a master running at
    `pe-<version>-master.puppetdebug.vlan` --- so ensure a VM with that
    hostname is configured and running before bringing up any agents.

  - <a id="pe-<version>-replica" /> **`pe-<version>-replica`**:
    Performs an agent installation of PE `<version>` on the guest VM and
    configures it as an HA replica.  The replica is configured to contact
    a master running at `pe-<version>-master.puppetdebug.vlan` --- so ensure
    a VM with that hostname is configured and running before bringing up the
    replica.
    - There can only be one replica, and this only works with 2016.5+

  - <a id="pe-<version>-compile" /> **`pe-<version>-compile`**:
    This role performs an agent installation of PE `<version>` on the guest VM and configures it as an compile master in the `PE Master` node group.
    The compile master is configured to contact a master running at `pe-<version>-master.puppetdebug.vlan` --- so ensure a VM with that hostname is configured and running before bringing up the compile master. This is only compatible with PE 2016+

#### POSS-Specific Roles

There are a few roles that assist with creating VMs that run Puppet Open Source Software (POSS).

  - <a id="poss-envpuppet" /> **`poss-envpuppet`**:
    Runs Puppet in guest machines directly from Git clones located on the host
    machine at `src/puppetlabs/`. This is useful for inspecting and debugging
    changes in behavior between versions without re-installing packages.

    The required Git clones can be created by running the following Rake task:

        rake setup:poss

  - <a id="poss-apt-repos" /> **`poss-apt-repos`**:
    Configures access to the official repositories at apt.puppetlabs.com for
    Debian and Ubuntu VMs.

  - <a id="poss-yum-repos" /> **`poss-yum-repos`**:
    Configures access to the official repositories at yum.puppetlabs.com for
    CentOS and Fedora VMs.

There are also roles for legacy POSS software:

  - <a id="poss-pc1-repos" /> **`poss-pc1-repos`**:
    Installs the [PuppetLabs
    PC1](https://puppet.com/docs/puppet/4.10/puppet_collections.html)
    repository
  - <a id="el-6-ruby193" /> **`el-6-ruby193`**: Provides Ruby 1.9.3 on EL6
  - <a id="el-6-ruby200" /> **`el-6-ruby200`**: Provides Ruby 2.0.0 on EL6
    (requires the role [`el-6-epel`](#el-6-epel))

### Bolt Based Provisioning

Bolt modules can now be used to do the provisoning and configuration of the machines. An example set of plans have been provided in the `Puppetfile.example` which will enable provisioning a PE infrastructure. To use the bolt plans from the `Puppetfile` the following steps can be followed.

  1. [Install Bolt](https://puppet.com/docs/bolt/latest/bolt_installing.html) as needed.
  2. Copy the `Puppetfile.example` to `Puppetfile` and add any additional modules.
  3. Install the modules with `vagrant bolt puppetfile install`.
  4. Copy the `config/bolt_vms.yaml.example` to `config/bolt_vms.yaml`.
  5. Update any parameters in the `roles` of the `config/bolt_vms.yaml` to specify PE versions or download locations.

The example VMs in the `config/bolt_vms.yaml` use custom roles at the bottom of the file. There are roles to deploy a PE master, agent, and compiler. See the [`deploy_pe`](https://forge.puppet.com/jarretlavallee/deploy_pe) module for more parameter information.

  - **pe_master**
    Installs the PE master on the VM using the specified parameters.
  - **pe_compiler**
    Installs a PE compiler from the PE master.
  - **pe_agent**
    Installs a PE agent from the PE master.

The roles define provisioners and triggers. More information on how to use the bolt triggers and provisioners can be found in the [`vagrant-bolt` documentation](https://github.com/oscar-stack/vagrant-bolt#config-builder).

This is currently only for *nix vagrant hosts. Windows vagrant host compatibility is in progress in the example plans.

## Extending and Contributing

The debugging kit can be thought of as a library of configuration and data for [Oscar](https://github.com/oscar-stack/oscar).
Data is loaded from two sets of YAML files:

```
config
└── *.yaml         # <-- User-specific customizations
data
└── puppet_debugging_kit
    └── *.yaml     # <-- The debugging kit library
```

Everything under `data/puppet_debugging_kit` is loaded first.
In order to avoid merge conflicts when the library is updated, these files should never be edited unless you plan to submit your changes as a pull request.

The contents of `config/*.yaml` are loaded next and can be used to extend or override anything provided by `data/puppet_debugging_kit`.
These files are not tracked by Git and are where user-specific customizations should go.

---
<p align="center">
  <img src="http://i.imgur.com/TFTT0Jh.png" />
</p>

[roles_yaml]: https://github.com/puppetlabs/puppet-debugging-kit/blob/internal/data/puppet_debugging_kit/roles.yaml
[vms_yaml_example]: https://github.com/puppetlabs/puppet-debugging-kit/blob/internal/config/vms.yaml.example
