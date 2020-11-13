require 'dry/effects'
require 'rt_tracker/repos/country_repo'

RSpec.describe RtTracker::Repos::CountryRepo do
  include Dry::Effects::Handler.Lock

  subject(:repo) { described_class.new }

  around { with_lock(&_1) }

  describe '#get' do
    let(:http_call) { double(:http_call) }

    context 'success' do
      before { deps['http_call'] = http_call }

      before do
        expect(http_call).to receive(:call).with(
          url: 'https://api.covid19api.com/country/russia',
          method: :get
        ).and_return(Success([200, {}, fixture('covid19api/countries-ru.json')]))
      end

      it 'makes a request and validates results' do
        data = repo.get('russia').value!
        expect(data.size).to eql(89)
        expect(data[0]).to eql(
          country_code: 'RU',
          confirmed: 910778,
          deaths: 15467,
          recovered: 721473,
          active: 173838,
          date: Time.new(2020, 8, 14)
        )
      end
    end

    context 'locking failed' do
      let(:failing_backend) { LockBackend::Failing }

      around { with_lock(failing_backend, &_1) }

      specify do
        expect(repo.get('russia')).to eql(Failure([:try_again_later]))
      end
    end
  end
end
