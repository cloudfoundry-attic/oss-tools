require 'logger'
require 'gerrit/cli/shell_runner'
require 'gerrit/cli/command/clone'
require 'gerrit/cli/command/help'
require 'gerrit/cli/command/push'
require 'gerrit/cli/errors'

module Gerrit
  module Cli
  end
end

class Gerrit::Cli::Dispatcher
  def initialize(logger=nil)
    @logger = logger ||  Logger.new(STDOUT)
    @logger.level = Logger::INFO

    runner = Gerrit::Cli::ShellRunner.new(logger)

    @commands = {
      'clone' => Gerrit::Cli::Command::Clone.new(logger, runner),
      'push'  => Gerrit::Cli::Command::Push.new(logger, runner),
    }

    @commands['help'] = Gerrit::Cli::Command::Help.new(logger, @commands)
  end

  def show_available_commands
    @logger.info("Usage: gerrit <command>\n")
    @logger.info("Available Commands:")
    @logger.info(@commands['help'].commands_summary)
  end

  def run_command(argv)
    if argv.empty?
      show_available_commands
    else
      args = argv.dup
      command_name = args.shift
      if command = @commands[command_name]
        command.run(args)
      else
        @logger.error("ERROR: Unknown command '#{command_name}'\n")
        show_available_commands
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
