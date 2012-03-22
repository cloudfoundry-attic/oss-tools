require 'logger'

require 'gerrit/cli/command/help'

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
      @commands['help'].show_command_summaries
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
  end
end
