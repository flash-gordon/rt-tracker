
RtTracker::App.boot(:redlock) do |app|
  init do
    require 'redlock'
  end

  start do
    client = ::Redlock::Client.new([app['env.redis.url']])
    app.register(:redlock, client)
  end
end
