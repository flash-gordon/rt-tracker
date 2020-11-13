require 'dry/effects'
require 'dry/monads'
require 'dry/schema'

module RtTracker
  module Repos
    class CountryRepo
      include ::Dry::Monads[:result, :do]
      include ::Dry::Effects.Lock
      include Import[gateway: 'gateways.covid19']

      CountryStats = ::Dry::Schema.JSON do
        required(:stats).array(:hash) do
          required(:country_code).value(:string)
          required(:confirmed).value(:integer)
          required(:deaths).value(:integer)
          required(:recovered).value(:integer)
          required(:active).value(:integer)
          required(:date).value(:time)
        end
      end

      def get(country_name)
        if lock([:country_data, country_name])
          data = yield gateway.get(path: "/country/#{country_name}")
          values = yield CountryStats.(stats: data)

          Success(values[:stats])
        else
          Failure[:try_again_later]
        end
      end
    end
  end
end
