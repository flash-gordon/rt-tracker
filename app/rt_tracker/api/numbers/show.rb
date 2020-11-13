require 'dry/effects'
require 'dry/monads'

module RtTracker
  module API
    module Numbers
      class Show
        include ::Dry::Monads[:result, :do]
        include ::Dry::Effects::Handler.Lock
        include Import[
          'fun.calculate_rt',
          'repos.country_repo',
          'lock_backend'
        ]

        def call(country)
          with_lock(lock_backend) do
            data = yield country_repo.get(country)
            cases = data.map { _1[:confirmed] }
            rt = yield calculate_rt.(cases)

            Success(
              country_code: data.first[:country_code],
              rt: rt
            )
          end
        end
      end
    end
  end
end
