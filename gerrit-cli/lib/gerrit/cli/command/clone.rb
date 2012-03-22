require 'logger'
require 'uri'

require 'gerrit/cli/command/base'
require 'gerrit/cli/constants'
require 'gerrit/cli/errors'

# A thin wrapper around git-clone that attempts to install commit-msg hooks
# that automatically insert the ChangeID lines used by Gerrit.
class Gerrit::Cli::Command::Clone < Gerrit::Cli::Command::Base
  def initialize(logger, runner)
    super(logger)

    @runner = runner
  end

  def setup_option_parser
    super

    @option_parser.banner =
      "Clone a Gerrit hosted repo and install commit-msg hooks."
  end

  def usage
    "Usage: gerrit clone [options] <repo> [<dir>]\n\n" + @option_parser.help
  end

  def run(argv)
    args = @option_parser.parse(argv)

    repo_uri, repo_dir = nil, nil
    case args.length
    when 2
      repo_uri, repo_dir = args
    when 1
      repo_uri = args[0]
    else
      raise Gerrit::Cli::UsageError.new("Incorrect number of arguments")
    end

    @runner.system!("git clone #{repo_uri} #{repo_dir}")

    # At this point the uri must be valid, otherwise the clone would have
    # failed
    parsed_repo_uri = URI.parse(repo_uri)

    unless repo_dir
      if parsed_repo_uri.path =~ /\/([^\/]+?)(.git)?$/
        repo_dir = $1
      else
        emsg = "Failed to determine the directory the repo was cloned into."
        raise Gerrit::Cli::Error.new(emsg)
      end
    end

    install_commit_hooks(parsed_repo_uri, repo_dir)
    install_tracked_hooks(repo_dir)
  end

  def install_commit_hooks(parsed_repo_uri, repo_dir)
    hook_src = "#{parsed_repo_uri.host}:hooks/commit-msg"
    if parsed_repo_uri.user
      hook_src = "#{parsed_repo_uri.user}@#{hook_src}"
    end

    hook_dst = "#{repo_dir}/.git/hooks"

    gerrit_port = parsed_repo_uri.port || Gerrit::Cli::DEFAULT_GERRIT_PORT

    @logger.info("\nInstalling commit-msg hooks into '#{hook_dst}'.")
    @runner.system!("scp -p -P #{gerrit_port} #{hook_src} #{hook_dst}")
  end

  def install_tracked_hooks(repo_dir)
    Dir.chdir(repo_dir) do
      if File.executable?("git/install-hook-symlinks")
        @logger.info("\nInstalling tracked git hooks: ")
        @runner.system!("git/install-hook-symlinks")
      end
    end
  end
end
