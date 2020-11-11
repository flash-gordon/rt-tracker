require_relative 'app'

RtTracker.boot(:logger)

RtTracker::App.finalize!
