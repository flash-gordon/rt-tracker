RtTracker::App.boot(:redis) do |app|
  init do
    require 'redis'
    require 'connection_pool'
  end

  start do
    pool = ConnectionPool.new(size: 30, timeout: 5) do
      Redis.new(url: app['env.redis.url'])
    end

    app.register(:redis, pool)
  end
end
