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
    @logger.info("+ #{command}")

    unless system(command)
      st = $?.exitstatus
      emsg = "Command '#{command}' exited with non-zero status (#{st})."
      raise Gerrit::Cli::Error.new(emsg)
    end
  end

  def capture!(command)
    @logger.info("+ #{command}")

    out = `#{command}`
    unless $?.success?
      st = $?.exitstatus
      emsg = "Command '#{command}' exited with non-zero status (#{st})."
      raise Gerrit::Cli::Error.new(emsg)
    end

    out
  end
end
