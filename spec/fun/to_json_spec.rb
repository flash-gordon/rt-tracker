require 'rt_tracker/fun/to_json'

RSpec.describe RtTracker::Fun::ToJSON do
  subject(:to_json) { described_class.new }

  specify 'hash' do
    expect(to_json.(foo: 'bar')).to eql('{"foo":"bar"}')
  end

  specify 'array' do
    expect(to_json.([foo: 'bar'])).to eql('[{"foo":"bar"}]')
  end

  specify 'other JSON types are intentionally not supported' do
    [1, 2.0, 'foo', nil, true].each do |value|
      expect {
        to_json.(value)
      }.to raise_error(ArgumentError, /is not a Hash or an Array/)
    end
  end

  specify 'non-serializable values' do
    [Object.new, timestamp].each do |value|
      expect {
        to_json.(foo: value)
      }.to raise_error(ArgumentError, /Cannot serialize/)
    end
  end
end
