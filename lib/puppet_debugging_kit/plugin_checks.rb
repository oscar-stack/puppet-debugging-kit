require 'vagrant/errors'
require 'oscar'
require 'vagrant-hosts'
require 'pe_build/version'

module PuppetDebuggingKit
  module PluginChecks
    class DebugKitBadVersion < Vagrant::Errors::VagrantError
      def initialize(plugin, required, actual)
        @error_message = "Outdated debugging kit dependency: #{plugin}\nMinimum required version is: #{required}\nInstalled version is: #{actual}\nTry: vagrant plugin update #{plugin}"

        super @error_message
      end

      def error_message; @error_message; end
    end

    REQUIRED_HOSTS          = Gem::Version.new('2.1.4')
    REQUIRED_OSCAR          = Gem::Version.new('0.4.0')
    REQUIRED_PEBUILD        = Gem::Version.new('0.10.0')

    # Performs sanity checks on required plugins.
    def self.run
      vagrant_version        = Gem::Version.new(Vagrant::VERSION)
      oscar_version          = Gem::Version.new(Oscar::VERSION)
      hosts_version          = Gem::Version.new(VagrantHosts::VERSION)
      pebuild_version        = Gem::Version.new(PEBuild::VERSION)

      if oscar_version < REQUIRED_OSCAR
        raise DebugKitBadVersion.new('oscar', REQUIRED_OSCAR, oscar_version)
      end

      if pebuild_version < REQUIRED_PEBUILD
        raise DebugKitBadVersion.new('vagrant-pe_build', REQUIRED_PEBUILD, pebuild_version)
      end

      if vagrant_version >= Gem::Version.new('1.5.0') && hosts_version < REQUIRED_HOSTS
        raise DebugKitBadVersion.new('vagrant-hosts', REQUIRED_HOSTS, hosts_version)
      end
    end
  end
end
