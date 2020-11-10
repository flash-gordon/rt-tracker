require 'rt_tracker/routes/number_api'

RSpec.describe RtTracker::Routes::NumberAPI do
  specify do
    get '/numbers/ping'

    expect(response.body).to eql('pong')
  end
end
