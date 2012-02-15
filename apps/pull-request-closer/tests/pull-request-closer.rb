require 'pull-request-closer'
require 'test/unit'
require 'rack/test'

class PullRequestCloserTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_my_default
    get '/'
    assert_equal 'Hello World!', last_response.body
  end

end
