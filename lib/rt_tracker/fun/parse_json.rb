require 'json'
require 'dry/monads'

module RtTracker
  module Fun
    class ParseJSON
      include ::Dry::Monads[:try, :result]

      def call(string)
        Try[::JSON::JSONError] {
          ::JSON.parse(string, symbolize_names: true)
        }.to_result
      end
    end
  end
end
