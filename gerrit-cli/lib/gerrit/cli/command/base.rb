require 'logger'
require 'optparse'

module Gerrit
  module Cli
    module Command
    end
  end
end

class Gerrit::Cli::Command::Base

  attr_reader :option_parser

  def initialize(logger)
    @logger = logger
    @option_parser = OptionParser.new

    setup_option_parser
  end

  def setup_option_parser
    @option_parser.on('-h', '--help', 'Display usage') do
      show_usage
      exit 0
    end

    @option_parser.on('-v', '--verbose', 'Show debugging information') do
      @logger.level = Logger::DEBUG
    end
  end

  def run(argv)
    raise NotImplementedError
  end

  def name
    self.class.name.split('::').last.downcase
  end

  def summary
    @option_parser.banner
  end

  def usage
    "Usage: gerrit #{name} [options]\n\n" + @option_parser.help
  end

  def show_error(message, opts={})
    @logger.error("ERROR: #{message}\n\n")
    show_usage if opts[:show_usage]
  end

  def show_usage
    @logger.info(usage())
  end
end
