require 'dry/effects'
require 'dry/monads'

module RtTracker
  module API
    module Numbers
      class Show
        include ::Dry::Monads[:result, :do]
        include ::Dry::Effects::Handler.Lock
        include ::Dry::Effects::Handler.Parallel
        include ::Dry::Effects.Parallel
        include Import[
          'fun.calculate_rt',
          'repos.country_repo',
          'lock_backend'
        ]

        EUROPE = %w(germany france uk)

        def call(country)
          with_lock(lock_backend) do
            case country
            in 'eu'
              with_parallel do
                all_cases = EUROPE.map do |eu_country|
                  par do
                    _, cases = yield country_cases(eu_country)
                    cases
                  end
                end

                rt = yield calculate_rt.(join(all_cases))

                Success(country_code: 'EU', rt: rt)
              end
            else
              code, cases = yield country_cases(country)

              rt = yield calculate_rt.([cases])

              Success(country_code: code, rt: rt)
            end
          end
        end

        def country_cases(country)
          data = yield country_repo.get(country)
          cases = data.map { _1[:confirmed] }

          country_code = data.first[:country_code]

          Success([country_code, cases])
        end
      end
    end
  end
end
