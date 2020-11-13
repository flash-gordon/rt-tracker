ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'

task :env do
  require File.expand_path('system/rt_tracker/boot',  __dir__)
end

task cli: :env do
  require_relative 'system/rt_tracker/cli_context'
  require 'pry-byebug'
  require 'rt_tracker/handlers_stack'
  stack = RtTracker::HandlersStack.new

  stack.() do
    cli = RtTracker::CLIContext.new
    prompt = Pry::Prompt.new(
      :rt_trackr,
      'Custom prompt',
      [proc { 'rt_tracker> ' }, proc { 'rt_tracker*> ' }]
    )
    Pry.start(cli, prompt: prompt)
  end
  abort
end
