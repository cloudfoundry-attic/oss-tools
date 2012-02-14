require 'rubygems'
require 'sinatra'
require 'octokit'
require 'YAML'
require 'net/http'

get '/' do
  thread = Thread.new { handle_pull_requests }
  "Pull request closer"
end

def handle_pull_requests
    puts "Logging into Github"
    client = Octokit::Client.new(:login => "leto", :oauth_token => ENV['CF_PULL_REQUEST_CLOSER_TOKEN'])

    # will need to add uaa and friends soon
    repos = %w| docs vmc vcap vcap-services vcap-java vcap-tests vcap-test-assets vcap-java-client|.map { |r| 'cloudfoundry/' + r }

    min_pr_num = {
        'vmc'              => 47,
        'vcap'             => 182,
        'docs'             => 0,
        'vcap-services'    => 15,
        'vcap-java'        => 9,
        'vcap-tests'       => 11,
        'vcap-test-assets' => 1,
        'vcap-java-client' => 8
    }
    warn "Going to handle pull requests for all repos"
    repos.each do |repo|
        puts "Handling pull requests for " + repo
        handle_pull_request(repo)
     end
end

def closing_message
    'Thanks for contributing to Cloud Foundry! We use Gerrit to track and manage contributions. Go to <a href="http://review.cloudfoundry.org">review.cloudfoundry.org</a> to upload your changes for review.'
end

def update_pull_request(repo, pr)
    puts "closing pr#" + pr + " in " + repo
    patch("repos/cloudfoundry/" + repo + "/pulls" + pr.number, {:state => 'closed', :body => pr.body + closing_message() } )
end

def handle_pull_request(repo)
    puts "Getting pull requests for " + repo
    pulls  = client.pulls(repo)
    puts "pulls=" + y(pulls)
    pulls.each do |pr|
        puts "Inspecting PR#" + pr.number
        if pr.number > min_pr_num[repo]
            update_pull_request(repo,pr)
        end
      end
end
