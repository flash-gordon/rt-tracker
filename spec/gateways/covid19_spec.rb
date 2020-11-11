require 'rt_tracker/gateways/covid19'

RSpec.describe RtTracker::Gateways::COVID19 do
  subject(:gateway) { described_class.new }

  let(:http_call) { double(:http_call) }

  before { deps['http_call'] = http_call }

  context 'default' do
    before do
      expect(http_call).to receive(:call).with(
        url: 'https://api.covid19api.com/',
        method: :get
      ).and_return(response)
    end

    context 'success' do
      let(:response) do
        Success([
          200,
          {},
          JSON.dump(
            "Global": {
              "NewConfirmed": 100282,
              "TotalConfirmed": 1162857,
              "NewDeaths": 5658,
              "TotalDeaths": 63263,
              "NewRecovered": 15405,
              "TotalRecovered": 230845
            },
            "Countries": [
              "Country": "ALA Aland Islands",
              "CountryCode": "AX",
              "Slug": "ala-aland-islands",
              "NewConfirmed": 0,
              "TotalConfirmed": 0,
              "NewDeaths": 0,
              "TotalDeaths": 0,
              "NewRecovered": 0,
              "TotalRecovered": 0,
              "Date": "2020-04-05T06:37:00Z"
            ]
          )
        ])
      end

      specify do
        expect(gateway.(path: '/')).to eql(
          Success(
            global: {
              new_confirmed: 100282,
              total_confirmed: 1162857,
              new_deaths: 5658,
              total_deaths: 63263,
              new_recovered: 15405,
              total_recovered: 230845
            },
            countries: [
              country: "ALA Aland Islands",
              country_code: "AX",
              slug: "ala-aland-islands",
              new_confirmed: 0,
              total_confirmed: 0,
              new_deaths: 0,
              total_deaths: 0,
              new_recovered: 0,
              total_recovered: 0,
              date: "2020-04-05T06:37:00Z"
          ])
        )
      end
    end

    context 'failure' do
      context 'invalid code' do
        let(:response) { Success([404, {}, 'whatever']) }

        specify do
          expect(gateway.(path: '/')).to eql(
            Failure([:bad_status_code, 404])
          )
        end
      end

      context 'invalid json' do
        let(:response) { Success([200, {}, 'invalid json']) }

        specify do
          result = gateway.(path: '/')

          expect(result).to be_a_failure
          expect(result.failure[0]).to eql(:invalid_json)
        end
      end
    end
  end
end
