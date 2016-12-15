require 'rubygems'
require 'vagrant/errors'

require 'oscar/version'

module PuppetDebuggingKit
  module PluginChecks
    class DebugKitBadVersion < Vagrant::Errors::VagrantError
      def initialize(plugin, required, actual)
        @error_message = "Outdated debugging kit dependency: #{plugin}\nMinimum required version is: #{required}\nInstalled version is: #{actual}\nTry running: vagrant plugin update"

        super @error_message
      end

      def error_message; @error_message; end
    end

    REQUIRED_OSCAR          = Gem::Requirement.new('>= 0.5.3')

    # Performs sanity checks on required plugins.
    def self.run
      oscar_version          = Gem::Version.new(Oscar::VERSION)

      unless REQUIRED_OSCAR.satisfied_by?(oscar_version)
        raise DebugKitBadVersion.new('oscar', REQUIRED_OSCAR.to_s, oscar_version)
      end
    end
  end
end
