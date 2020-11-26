require 'roda'
require 'dry/monads'

module RtTracker
  module Routes
    class NumberAPI < ::Roda
      include ::Dry::Monads[:result]
      include Import[
        'api.numbers.show',
        'fun.to_json'
      ]

      plugin :status_handler

      status_handler(404) do
        to_json.(error: 'country not found')
      end

      status_handler(425) do
        to_json.(error: 'not enough data collected')
      end

      status_handler(429) do
        to_json.(error: 'try again later')
      end

      status_handler(503) do
        to_json.(error: 'service unavailable')
      end

      route do |r|
        r.get :country do |country|
          case show.(country)
          in Success(result)
            to_json.(result)
          in Failure[:not_enough_values]
            response.status = 425
            nil
          in Failure[:try_again_later]
            response.status = 429
            nil
          in Failure[:bad_status_code, 404]
            response.status = 404
            nil
          in Failure
            response.status = 503
            nil
          end
        end
      end
    end
  end
end
