require_relative 'app'

require 'bundler/require'

RtTracker::App.start(:logger)
RtTracker::App.start(:api)
RtTracker::App.start(:redis)
RtTracker::App.start(:redlock)
RtTracker::App.auto_register!('app') do |config|
  config.exclude do
    %r{/routes/}.match?(_1.path)
  end
end
RtTracker::App.auto_register!('lib')
RtTracker::App.finalize!
