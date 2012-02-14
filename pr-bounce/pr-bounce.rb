# Copyright (C) 2012 VMware, Inc. All rights reserved.
require "rubygems"
require "octokit"
require "logger"
require "YAML"

def handle_pull_requests
  log    = create_logger()
  log.info("Loading config")
  config = load_config()

  # trying to use oauth is a tragedy
  client = Octokit::Client.new(
    :login    => config["username"],
    :password => ENV["PR_BOUNCE_PASSWORD"] || config["password"]
  )
  log.info("Logged into Github with #{config['username']}")
  org    = config['organization']

  log.info("Grabbing all public repos for #{org}")
  repos  = client.organization_repositories(org)

  repos.each do |repo|
    handle_pull_request(log, config, client, org, repo["name"])
  end
end

def create_logger
  log       = Logger.new(STDOUT)
  log.level = Logger::INFO
  return log
end

def load_config
  config = YAML::load( File.open( ENV["PR_BOUNCE_CONFIG"] || "config.yaml" ) )
  return config
end

def update_pull_request(log, config, client, org, repo, pr)
  closing_template = IO.read(config['templates']['closing'])

  log.info("Closing PR##{pr.number} #{org}/#{repo} at #{pr.url}")

  url = "repos/#{org}/#{repo}/pulls/#{pr.number}"

  begin
    client.patch(url, {:state => 'closed', :body => pr.body + closing_template})
  rescue => err
    log.fatal("Could not close PR#{pr.number}")
    log.fatal(err)
  end
end

def handle_pull_request(log, config, client, org, repo)
  log.info("Getting pull requests for #{repo}")

  pulls      = client.pulls(org + "/" + repo)
  min_pr_num = config['min_pr_num'][repo] || 0

  pulls.each do |pr|
      if pr.number > min_pr_num
        update_pull_request(log, config, client, org, repo, pr)
      end
    end
end

handle_pull_requests()
