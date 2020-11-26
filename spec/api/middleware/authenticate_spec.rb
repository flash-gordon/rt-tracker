require 'dry/effects'
require 'rt_tracker/api/middleware/authenticate'

RSpec.describe RtTracker::API::Middleware::Authenticate do
  include Dry::Effects::Handler.State(:authenticated)
  include Dry::Effects.State(:authenticated)
  include Dry::Effects::Handler.Env(
    'RT_TRACKER_API_KEY' => 'gimmert'
  )

  around { with_authenticated(false, &_1) }

  around { with_env(&_1) }

  subject(:authenticate) { described_class.new(app) }

  let(:app) do
    lambda do |_env|
      self.authenticated = true
      [200, {}, [""]]
    end
  end

  context 'valid key' do
    specify do
      authenticate.({'HTTP_X_TRACKER_API_KEY' => 'gimmert'})

      expect(authenticated).to be(true)
    end
  end

  context 'missing key' do
    specify do
      case authenticate.({})
      in 403, {}, ['Not authorized']
        expect(authenticated).to be(false)
      end
    end
  end

  context 'invalid key' do
    specify do
      case authenticate.({'HTTP_X_TRACKER_API_KEY' => 'wow'})
      in 403, {}, ['Not authorized']
        expect(authenticated).to be(false)
      end
    end
  end

  context 'missing config' do
    around { with_env({'RT_TRACKER_API_KEY' => nil}, &_1) }

    specify do
      case authenticate.({})
      in 403, {}, ['Not authorized']
        expect(authenticated).to be(false)
      end
    end
  end

  context 'invalid config' do
    around { with_env({'RT_TRACKER_API_KEY' => ''}, &_1) }

    specify do
      case authenticate.({})
      in 403, {}, ['Not authorized']
        expect(authenticated).to be(false)
      end
    end
  end
end
