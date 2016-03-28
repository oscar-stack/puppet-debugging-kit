require 'vagrant/errors'
require 'oscar'
require 'vagrant-hosts'
require 'pe_build/version'
require 'config_builder/version'

module PuppetDebuggingKit
  module PluginChecks
    class DebugKitBadVersion < Vagrant::Errors::VagrantError
      def initialize(plugin, required, actual)
        @error_message = "Outdated debugging kit dependency: #{plugin}\nMinimum required version is: #{required}\nInstalled version is: #{actual}\nTry running: vagrant plugin update"

        super @error_message
      end

      def error_message; @error_message; end
    end

    REQUIRED_OSCAR          = Gem::Version.new('0.5.0')

    # Performs sanity checks on required plugins.
    def self.run
      oscar_version          = Gem::Version.new(Oscar::VERSION)

      if oscar_version < REQUIRED_OSCAR
        raise DebugKitBadVersion.new('oscar', REQUIRED_OSCAR, oscar_version)
      end
    end
  end
end
