require 'dry/monads'

module RtTracker
  module Gateways
    class COVID19
      include ::Dry::Monads[:result, :do]
      include Import[
        'inflector',
        'fun.parse_json',
        'http_call'
      ]

      HOST = 'https://api.covid19api.com'

      def get(path:)
        code, _headers, body = yield http_call.(url: "#{HOST}#{path}", method: :get)

        if code.eql?(200)
          case parse_json.(body)
          in Success(json)
            Success(transform_response(json))
          in Success(*json)
            Success(transform_response(json))
          in Failure(error)
            Failure[:invalid_json, error]
          end
        else
          Failure[:bad_status_code, code]
        end
      end

      def transform_response(json)
        case json
        in ::Array
          json.map { transform_response(_1) }
        in ::Hash
          json.to_h do
            k = inflector.underscore(_1).to_sym
            v = transform_response(_2)
            [k, v]
          end
        else
          json
        end
      end
    end
  end
end
