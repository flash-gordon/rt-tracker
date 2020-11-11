require 'rt_tracker/fun/parse_json'

RSpec.describe RtTracker::Fun::ParseJSON do
  subject(:parse_json) { described_class.new }

  specify 'success' do
    expect(parse_json.('{"foo": "bar"}')).to eql(Success(foo: 'bar'))
  end

  specify 'error' do
    result = parse_json.('{foo: "bar"}')
    expect(result).to be_a_failure
    expect(result.failure).to be_a(JSON::ParserError)
    expect(result.failure.message).to match(/unexpected token/)
  end
end
