# -*- mode: ruby -*-
# vi: set ft=ruby :

# Hammer out a couple of kinks related to Vagrant plugins
if defined?(Bundler)
  # When running under Bundler, Vagrant disables plugins. We use a Bundler group
  # to simulate the auto-loading that Vagrant normally does when plugins are
  # enabled.
  Bundler.require(:vagrant_plugins)
else
  # Vagrant also disables plugins when running the plugin face, but does load
  # the Vagrantfile. Thus, running `vagrant plugin` in a directory influenced
  # by this Vagrantfile will fail with "uninitialized constant Oscar" unless we
  # ensure Oscar is loaded.
  require 'oscar' unless defined?(Oscar)
end

Vagrant.configure('2', &Oscar.run(File.expand_path('../config', __FILE__)))
