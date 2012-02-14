require 'pull-request-closer'
require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

set :environment, :test

describe 'The pull-request-closer App' do
  def app
    Sinatra::Application
  end

  it "says hello" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Pull request closer'
  end
end
