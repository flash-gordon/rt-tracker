require 'rt_tracker/api/numbers/show'

RSpec.describe RtTracker::API::Numbers::Show do
  subject(:show) { described_class.new }

  let(:repo) { double(:repo) }

  before { deps['repos.country_repo'] = repo }

  context 'single country' do
    before do
      expect(repo).to receive(:get).with('ru').and_return(response)
    end

    context 'success' do
      let(:response) do
        Success([confirmed: 100, country_code: 'RU'] * 8)
      end

      specify do
        expect(show.('ru')).to eql(
          Success(country_code: 'RU', rt: 1.0)
        )
      end
    end

    context 'not enough data' do
      let(:response) do
        Success([confirmed: 100, country_code: 'RU'] * 7)
      end

      specify do
        expect(show.('ru')).to eql(
          Failure([:not_enough_values])
        )
      end
    end
  end

  context 'europe' do
    let(:countries) do
      { 'germany' => 'de', 'france' => 'fr', 'uk' => 'gb' }
    end

    before do
      countries.each do |country, code|
        expect(repo).to receive(:get).with(country).and_return(
          Success(
            Array.new(8) { |i|
              { confirmed: (i + 1) * 100, country_code: code }
            }
          )
        )
      end
    end

    specify do
      expect(show.('eu')).to eql(
        Success(country_code: 'EU', rt: 2.6)
      )
    end
  end
end
