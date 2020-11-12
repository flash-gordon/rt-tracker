require_relative 'app'

RtTracker::App.start(:logger)
RtTracker::App.auto_register!('app') do |config|
  config.exclude do
    %r{/routes/}.match?(_1.path)
  end
end
RtTracker::App.auto_register!('lib')
RtTracker::App.finalize!
