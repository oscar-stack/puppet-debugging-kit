# -*- mode: ruby -*-
# vi: set ft=ruby :

# Hammer out a couple of kinks related to Vagrant plugins
if defined? Bundler
  # When running under Bundler, Vagrant disables plugins. We use a Bundler group
  # to simulate the auto-loading that Vagrant normally does when plugins are
  # enabled.
  Bundler.require :vagrant_plugins
end

# Don't do anything if Oscar is not loaded.
Vagrant.configure('2', &Oscar.run(File.expand_path('../config', __FILE__))) if defined? Oscar
