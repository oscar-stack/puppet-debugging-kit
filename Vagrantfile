# -*- mode: ruby -*-
# vi: set ft=ruby :

vagrant_dir = File.dirname(__FILE__)
# The chdir ensures all relative paths expand consistently no matter where
# the vagrant command is run from.
Dir.chdir(vagrant_dir)

require_relative 'lib/puppet_debugging_kit/logging'

if defined? Oscar # Do nothing if Oscar isn't loaded.
  require_relative 'lib/puppet_debugging_kit'
  PuppetDebuggingKit::PluginChecks.run

  # Oscar will load all YAML files in each directory listed below. Directories
  # that appear later in the array will append or overwrite config loaded from
  # directories that appear first in the array. The deep_merge gem is used to
  # effect this behavior.
  config_dirs = %w[
    data/puppet_debugging_kit
    config
  ].map{|d| File.expand_path(d, vagrant_dir)}

  Vagrant.configure('2', &ConfigBuilder.load(:yaml_erb, :yamldir, config_dirs))
else
  PuppetDebuggingKit::Logging.global_logger.warn 'Oscar not available. No VMs will be defined.'
end
