require 'dry/monads'

module RtTracker
  module Fun
    class CalculateRt
      include ::Dry::Monads[:result, :do]

      def call(series, interval: 4)
        xs = series.map do |values|
          if values.size < interval * 2
            yield Failure[:not_enough_values]
          else
            values[-interval * 2...].map { Float(_1) }
          end
        end

        ys = xs.first.zip(*xs.drop(1)).map { _1.sum }

        Success(ys.drop(interval).sum / ys.take(interval).sum).fmap { _1.round(2) }
      end
    end
  end
end
