require 'dry/monads'

module RtTracker
  module Fun
    class CalculateRt
      include ::Dry::Monads[:result]

      def call(values, interval: 4)
        if values.size < interval * 2
          Failure[:not_enough_values]
        else
          xs = values[-interval * 2...].map { Float(_1) }
          Success(xs.drop(interval).sum / xs.take(interval).sum).fmap { _1.round(2) }
        end
      end
    end
  end
end
