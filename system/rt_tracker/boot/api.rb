RtTracker::App.boot(:api) do |app|
  start do
    ::Dir["#{app.root}/app/rt_tracker/routes/**/*.rb"].sort.each do |path|
      require path.sub(app.root.to_s, '')[%r{/(rt_tracker/[^\.]+)\.rb\z}, 1]
    end
  end
end
