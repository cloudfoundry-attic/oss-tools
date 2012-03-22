require 'logger'

require 'gerrit/cli/command/help'
require 'gerrit/cli/errors'

module Gerrit
  module Cli
  end
end

class Gerrit::Cli::Dispatcher
  def initialize(logger=nil)
    @logger = logger ||  Logger.new(STDOUT)

    @commands = {}

    @commands['help'] = Gerrit::Cli::Command::Help.new(logger, @commands)
  end

  def run_command(argv)
    if argv.empty?
      @logger.info("Available Commands:")
      @logger.info(@commands['help'].commands_summary)
    else
      args = argv.dup
      command_name = args.shift
      if command = @commands[command_name]
        command.run(args)
      else
        @logger.error("ERROR: Unknown command '#{command_name}'")
        @commands['help'].show_command_summaries
      end
    end
  rescue Gerrit::Cli::UsageError => ue
    @logger.error("ERROR: #{ue}\n")
    command.show_usage
    exit 1
  rescue => e
    @logger.error("ERROR: #{e}")
    @logger.debug(e.backtrace.join("\n")) if e.backtrace
    exit 1
  end
end
