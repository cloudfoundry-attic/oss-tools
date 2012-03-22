require 'logger'

require 'gerrit/cli/errors'

module Gerrit
  module Cli
  end
end

class Gerrit::Cli::ShellRunner
  def initialize(logger)
    @logger = logger || Logger.new(STDOUT)
  end

  def system!(command)
    @logger.debug("+ #{command}")

    unless system(command)
      st = $?.exitstatus
      emsg = "Command '#{command}' exited with non-zero status (#{st})."
      raise Gerrit::Cli::Error.new(emsg)
    end
  end
end
