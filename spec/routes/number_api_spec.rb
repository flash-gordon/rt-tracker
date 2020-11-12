require 'rt_tracker/routes/number_api'

RSpec.describe RtTracker::Routes::NumberAPI do
  include Dry::Effects::Handler.Random
  include Dry::Effects.Random

  let(:gateway) { double(:gateway) }

  let(:current_date) { tc(current_time) { _1.floor(:day) } }

  around { with_random(seed: 314, &_1) }

  describe 'GET /numbers/:country' do
    let(:country_data) do
      Array.new(20) do |i|
        {
          country_code: 'RU',
          confirmed: rand(100_000..200_000),
          deaths: rand(100_500),
          recovered: rand(100_500),
          active: rand(100_500),
          date: tc(current_date) { _1.+(i, :days) }
        }
      end
    end

    before { deps['gateways.covid19'] = gateway }

    context 'success' do
      before do
        expect(gateway).to receive(:get).with(
          path: '/countries/russia'
        ).and_return(Success(country_data))
      end

      specify do
        get '/numbers/russia'

        expect(status).to eql(200)
        expect(json_response).to eql(country_code: 'RU', rt: 0.88)
      end
    end

    context 'failure' do
      context 'COVID API failure' do
        before do
          expect(gateway).to receive(:get).with(
            path: '/countries/russia'
          ).and_return(Failure('💥'))
        end

        specify do
          get '/numbers/russia'

          expect(status).to eql(503)
          expect(json_response).to eql(error: 'service unavailable')
        end
      end

      context 'Rt calculation error' do
        before do
          expect(gateway).to receive(:get).with(
            path: '/countries/russia'
          ).and_return(Success(country_data.take(3)))
        end

        specify do
          get '/numbers/russia'

          expect(status).to eql(425)
          expect(json_response).to eql(error: 'not enough data collected')
        end
      end
    end
  end
end
