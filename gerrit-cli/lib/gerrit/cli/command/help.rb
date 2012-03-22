require 'gerrit/cli/command/base'
require 'gerrit/cli/util'

class Gerrit::Cli::Command::Help < Gerrit::Cli::Command::Base
  def initialize(logger, commands)
    super(logger)

    @commands = commands.dup.merge(self.name => self)
  end

  def setup_option_parser
    super

    @option_parser.banner =
      "Show a list of commands or display help for a specific command."
  end

  def usage
    "Usage: gerrit help [options] [command]\n\n" + @option_parser.help
  end

  def run(argv)
    args = @option_parser.parse(argv)

    case args.length
    when 1
      if command = @commands[args[0]]
        command.show_usage
      else
        show_error("Unknown command '#{args[0]}'")
        show_command_summaries
      end
    when 0
      show_command_summaries
    else
      show_error("Too many arguments", :show_usage => true)
    end
  end

  def show_command_summaries
    rows = @commands.keys.sort.map {|k| [k, @commands[k].summary] }
    summaries = Gerrit::Cli::Util.render_table(rows)
    @logger.info("Commands:\n\n")
    @logger.info(summaries)
    @logger.info("\n")
  end
end
