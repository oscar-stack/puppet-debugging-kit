require 'log4r'

# Sooo. Lots of things in the debugging kit happen before Vagrant is fully
# initialized and running commands (because the config hasn't been built and is
# not executing).
#
# This means we don't have access to the Vagrant::UI framework for output
# handling. This module is a simple workaround that sets up Log4r loggers that
# can be used to communicate with users.
#
# NOTE: Currently, everything here assumes that debug kit users are running
# Vagrant interactively from the command line.
module PuppetDebuggingKit
  module Logging
   class << self; attr_accessor :global_logger; end

   @global_logger = Log4r::Logger.new('puppet_debugging_kit')
   # Send our chatter to stderr so it doesn't accidentally mix with any output.
   @global_logger.add(Log4r::Outputter.stderr)
  end
end
