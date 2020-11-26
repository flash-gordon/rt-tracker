require 'rt_tracker/fun/calculate_rt'

RSpec.describe RtTracker::Fun::CalculateRt do
  subject(:calc) { described_class.new }

  example 'not enough values' do
    expect(calc.([[1, 2, 3]])).to eql(Failure([:not_enough_values]))
  end

  example 'rising' do
    expect(calc.([[*1..8]])).to eql(Success(2.6))
  end

  example 'constant' do
    expect(calc.([[10] * 10])).to eql(Success(1.0))
  end

  example 'going down' do
    expect(calc.([[*1..8].reverse])).to eql(Success(0.38))
  end

  example 'only last numbers are counted' do
    expect(calc.([[*1..8] + [5] * 8])).to eql(Success(1.0))
  end

  example 'interval can be changed' do
    expect(calc.([[*1..10]], interval: 5)).to eql(Success(2.67))
  end

  context 'multiple inputs' do
    example 'rising' do
      expect(calc.([[*1..8], [*1..8]])).to eql(Success(2.6))
    end

    example 'not enough values' do
      expect(calc.([[*1..8], [1, 2, 3]])).to eql(Failure([:not_enough_values]))
    end

    example 'non-even lengths' do
      expect(calc.([[*3..10], [*1..10]])).to eql(Success(1.89))
    end
  end
end
