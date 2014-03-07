# -*- mode: ruby -*-
# vi: set ft=ruby :

# Hammer out a couple of kinks related to Vagrant plugins
if defined? Bundler
  # When running under Bundler, Vagrant disables plugins. We use a Bundler group
  # to simulate the auto-loading that Vagrant normally does when plugins are
  # enabled.
  Bundler.require :vagrant_plugins
else
  Vagrant.require_plugin('oscar')
end

if defined? Oscar
  vagrant_dir = File.dirname(__FILE__)
  # Oscar will load all YAML files in each directory listed below. Directories
  # that appear later in the array will append or overwrite config loaded from
  # directories that appear first in the array. The deep_merge gem is used to
  # effect this behavior.
  config_dirs = %w[
    data/puppet-debugging-kit
    config
  ].map{|d| File.expand_path(d, vagrant_dir)}

  Vagrant.configure('2', &Oscar.run(config_dirs))
end
