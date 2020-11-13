require 'rt_tracker/tagged_logger'

module RtTracker
  class HandlersStack
    include ::Dry::Effects::Handler.Resolve
    include ::Dry::Effects::Handler.Timestamp
    include Import['env.test']

    def call
      provide(App) do
        TaggedLogger.() do
          with_timestamp do
            yield
          end
        end
      end
    end
  end
end
