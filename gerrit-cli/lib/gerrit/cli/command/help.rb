require 'gerrit/cli/command/base'
require 'gerrit/cli/errors'
require 'gerrit/cli/util'

class Gerrit::Cli::Command::Help < Gerrit::Cli::Command::Base

  attr_reader :commands_summary

  def initialize(logger, commands)
    super(logger)

    @commands = commands.dup.merge(self.name => self)

    rows = @commands.keys.sort.map {|k| [k, @commands[k].summary] }
    @commands_summary = Gerrit::Cli::Util.render_table(rows,
                                                       :delimiter => '  ')
  end

  def setup_option_parser
    super

    @option_parser.banner =
      "Show a list of commands or display help for a specific command."
  end

  def usage
    "Usage: gerrit help [options] [<command>]\n\n" \
    + @option_parser.help                          \
    + "\nAvailable commands:\n"                    \
    + @commands_summary
  end

  def run(argv)
    args = @option_parser.parse(argv)

    case args.length
    when 1
      if command = @commands[args[0]]
        command.show_usage
      else
        raise Gerrit::Cli::UsageError.new("Unknown command '#{args[0]}'")
      end
    when 0
      show_usage
    else
      raise Gerrit::Cli::UsageError.new("Too many arguments")
    end
  end
end
