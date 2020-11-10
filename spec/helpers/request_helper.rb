require 'rack/test'

module RequestHelper
  include Rack::Test::Methods

  def app
    RtTracker::Routes::API.app
  end

  def response
    last_response
  end
end
