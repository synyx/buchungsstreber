require 'buchungsstreber/config'

RSpec.describe Buchungsstreber::Config do
  context 'when default configuration is loaded' do
    config = described_class.load('example.config.yml')

    it 'should not be empty' do
      expect(config).to_not be_empty
    end

    it 'returns keys as symbols' do
      config.each { |k, _| expect(k).to be_a(Symbol) }
    end

    it 'adds additional configuration from file' do
      expect(config[:redmines]).to_not be_nil
    end

    it 'uses default configuration values' do
      expect(config[:hours]).to be(8)
    end

    it 'throws exception if file not found' do
      expect { described_class.load('__non_existant__.yml') }.to raise_error(/file not found/)
    end
  end
end
