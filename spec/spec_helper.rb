ENV['RACK_ENV'] = 'test'
Warning[:experimental] = false

require 'pry-byebug'
require_relative '../system/rt_tracker/app'

require 'faker'
require 'super_diff/rspec'
require 'time_calc'
require 'warning'

require 'dry/effects'
require 'dry/monads'

Warning.ignore(/roda/)
Warning.process { raise RuntimeError, _1 } unless ENV['NO_RAISE_ON_WARNING']

SPEC_ROOT = __dir__

Dry::Effects.load_extensions(:rspec)

RtTracker::App.init(:logger)

Dir["#{SPEC_ROOT}/support/**/*.rb"].sort.each { require _1 }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end

  config.define_derived_metadata(file_path: %r{spec/routes}) do |metadata|
    metadata[:routes] = true
  end

  config.when_first_matching_example_defined :routes do
    require 'rt_tracker/routes/api'
    require_relative 'helpers/request_helper'

    config.include RequestHelper, :routes
  end

  config.when_first_matching_example_defined :webrick do
    require_relative 'helpers/webrick_helper'

    config.include WEBrickHelper, :webrick
  end

  config.include FixtureHelper

  config.include Dry::Monads[:result]
  config.include Dry::Effects::Handler.Resolve(RtTracker::App)
  config.include Dry::Effects::Handler.CurrentTime
  config.include Dry::Effects::Handler.Timestamp
  config.include Module.new {
    extend RSpec::SharedContext
    let(:deps) { {} }

    def tc(time)
      (yield TimeCalc.wrap(time)).unwrap
    end
  }

  config.around do |ex|
    provide(deps) do
      RtTracker::TaggedLogger.() do
        with_timestamp do
          with_current_time do
            ex.run
          end
        end
      end
    end
  end

  config.include Dry::Effects.CurrentTime
  config.include Dry::Effects.Timestamp

  config.disable_monkey_patching!

  config.warnings = true

  config.order = :random

  Kernel.srand config.seed

  config.backtrace_exclusion_patterns << /\/gems\//
  config.backtrace_exclusion_patterns << /\/spec_helper\.rb/
end
