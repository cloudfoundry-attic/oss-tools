# Copyright (C) 2012 VMware, Inc. All rights reserved.
require 'rubygems'
require 'octokit'
require 'YAML'
require 'net/http'

def handle_pull_requests
    puts "Logging into Github"
    # trying to use oauth is a tragedy
    # this should be a dedicated Github user
    client = Octokit::Client.new( :login => 'leto', :password => ENV['PR_BOUNCE_PASSWORD'] )

    config = YAML::load( File.open( 'config.yaml' ) )
    org = config['organization']

    warn "Grabbing all public repos for #{org}"
    repos = client.organization_repositories(org)

    repos.each do |repo|
        handle_pull_request(config, client, org, repo['name'])
     end
end

def closing_message
# This will be the message once our public Gerrit is ready
#    'Thanks for contributing to Cloud Foundry! We use Gerrit to track and manage contributions. Go to <a href="http://review.cloudfoundry.org">review.cloudfoundry.org</a> to upload your changes for review.'
    "\nThanks for contributing to Cloud Foundry! We use Gerrit to track and manage contributions.\n -- Your Friendly Gerrit Bot"
end

def update_pull_request(client, org, repo, pr)
    puts "Closing PR##{pr.number} #{org}/#{repo}"
    url = "repos/#{org}/#{repo}/pulls/#{pr.number}"
    client.patch(url, {:state => 'closed', :body => pr.body + closing_message() } )
end

def handle_pull_request(config, client, org, repo)
    puts "Getting pull requests for " + repo
    pulls  = client.pulls(org + "/" + repo)
    pulls.each do |pr|
        if pr.number > config['min_pr_num'][repo]
            update_pull_request(client, org, repo, pr)
        end
      end
end

handle_pull_requests()
