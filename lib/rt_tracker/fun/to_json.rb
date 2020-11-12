require 'oj'

module RtTracker
  module Fun
    class ToJSON
      OPTIONS = { mode: :strict }

      def call(value)
        if !value.is_a?(::Hash) && !value.is_a?(::Array)
          raise ::ArgumentError, "#{value.inspect} is not a Hash or an Array"
        else
          begin
            ::Oj.dump(value, OPTIONS)
          rescue ::TypeError => error
            raise ::ArgumentError, "Cannot serialize #{value.inspect}\n#{error.full_message}"
          end
        end
      end
    end
  end
end
