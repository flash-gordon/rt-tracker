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

      route do |r|
        r.get :country do |country|
          case show.(country)
          in Success(result)
            to_json.(result)
          in Failure
            'error'
          end
        end
      end
    end
  end
end
