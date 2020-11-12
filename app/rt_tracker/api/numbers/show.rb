require 'dry/monads'

module RtTracker
  module API
    module Numbers
      class Show
        include ::Dry::Monads[:result, :do]
        include Import[
          'fun.calculate_rt',
          'repos.country_repo'
        ]

        def call(country)
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
