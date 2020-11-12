require 'rt_tracker/tagged_logger'

module RtTracker
  class HandlersStack
    include ::Dry::Effects::Handler.Resolve
    include Import['env.test']

    def call
      provide(App) do
        TaggedLogger.() do
          yield
        end
      end
    end
  end
end
