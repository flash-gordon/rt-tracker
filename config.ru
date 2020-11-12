# This file is used by Rack-based servers to start the application.

$stdout.sync = true
$stderr.sync = true

require_relative 'system/rt_tracker/boot'
require 'rt_tracker/routes/api'

run RtTracker::Routes::API.app
