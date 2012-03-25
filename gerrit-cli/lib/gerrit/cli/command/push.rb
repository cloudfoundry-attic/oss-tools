require 'uri'

require 'gerrit/cli/command/base'
require 'gerrit/cli/constants'
require 'gerrit/cli/errors'

# Posts reviews to Gerrit. Assumes that your repo has at least one Gerrit
# remote.
class Gerrit::Cli::Command::Push < Gerrit::Cli::Command::Base
  def initialize(logger, runner)
    super(logger)

    @branch = "master"
    @runner = runner
  end

  def setup_option_parser
    super

    @option_parser.banner =
      "Post changes from the current branch to Gerrit for review."

    @option_parser.on('-b', '--branch BRANCH',
                      "The remote branch these changes should be merged into." \
                      + "Master is assumed by default.") do |branch|
      @branch = branch
    end
  end

  def usage
    "Usage: gerrit push [options] [<remote>]\n\n" + @option_parser.help
  end

  def run(argv)
    args = @option_parser.parse(argv)

    remote = nil
    case args.length
    when 1
      remote = args[0]
    when 0
      remote = "origin"
    else
      raise Gerrit::Cli::UsageError.new("Incorrect number of arguments")
    end

    topic = get_current_branch()

    cmd = ["git push",
           remote,
           "HEAD:refs/for/#{@branch}/#{topic}"].join(" ")
    @runner.system!(cmd)
  end

  def get_current_branch
    @logger.debug("Getting current branch")
    output = @runner.capture!("git symbolic-ref HEAD")
    output.gsub(/^refs\/heads\//,"")
  end
end
