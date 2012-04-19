require 'gerrit/cli/command/base'
require 'gerrit/cli/errors'
require 'gerrit/cli/util'

class Gerrit::Cli::Command::Help < Gerrit::Cli::Command::Base

  attr_reader :commands_summary

  def initialize(logger, commands)
    super(logger)

    @commands = commands.dup.merge(self.name => self)

    rows = @commands.keys.sort.map {|k| [k, @commands[k].summary] }
    indented_rows = rows.map {|cmd,smry| ["    " + cmd,smry]}
    @commands_summary = Gerrit::Cli::Util.render_table(indented_rows,
                                                       :delimiter => '  ')
  end

  def setup_option_parser
    super

    @option_parser.banner =
      "Show a list of commands or display help for a specific command."
  end

  def usage
    "Usage: gerrit help [options] [<command>]\n" \
    + "\nAvailable options:\n"                   \
    + @option_parser.summarize.join              \
    + "Available commands:\n"                    \
    + @commands_summary.to_s
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
