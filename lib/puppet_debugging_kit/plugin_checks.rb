require 'vagrant/errors'
require 'vagrant-config_builder'
require 'vagrant-hosts'
require 'vagrant-pe_build'

module PuppetDebuggingKit
  module PluginChecks
    class DebugKitBadVersion < Vagrant::Errors::VagrantError
      def initialize(plugin, required, actual)
        @error_message = "Outdated debugging kit dependency: #{plugin}\nMinimum required version is: #{required}\nInstalled version is: #{actual}\nTry: vagrant plugin update #{plugin}"

        super
      end

      def error_message; @error_message; end
    end

    REQUIRED_CONFIG_BUILDER = Gem::Version.new('0.7.1')
    REQUIRED_HOSTS          = Gem::Version.new('2.1.3')
    REQUIRED_PE_BUILD       = Gem::Version.new('0.8.6')

    # Performs sanity checks on required plugins.
    def self.run
      vagrant_version        = Gem::Version.new(Vagrant::VERSION)
      config_builder_version = Gem::Version.new(ConfigBuilder::VERSION)
      hosts_version          = Gem::Version.new(VagrantHosts::VERSION)
      pe_build_version       = Gem::Version.new(PEBuild::VERSION)

      if config_builder_version < REQUIRED_CONFIG_BUILDER
        raise DebugKitBadVersion.new('vagrant-config_builder', REQUIRED_CONFIG_BUILDER, config_builder_version)
      end

      if pe_build_version < REQUIRED_PE_BUILD
        raise DebugKitBadVersion.new('vagrant-pe_build', REQUIRED_PE_BUILD, pe_build_version)
      end

      if vagrant_version >= Gem::Version.new('1.5.0') && hosts_version < REQUIRED_HOSTS
        raise DebugKitBadVersion.new('vagrant-hosts', REQUIRED_HOSTS, hosts_version)
      end
    end
  end
end
