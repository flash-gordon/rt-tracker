module FixtureHelper
  def fixture(path)
    ::File.read("#{SPEC_ROOT}/fixtures/#{path}")
  end
end
