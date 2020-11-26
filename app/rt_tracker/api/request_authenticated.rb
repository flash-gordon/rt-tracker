require 'dry/effects'

module RtTracker
  module API
    class RequestAuthenticated
      include ::Dry::Effects.Env(secret: 'RT_TRACKER_API_KEY')

      HEADER = 'HTTP_X_TRACKER_API_KEY'

      def call(env)
        api_key = env[HEADER]

        !secret.nil? && !secret.empty? && api_key.eql?(secret)
      end
    end
  end
end
