require 'config'

describe Config do
  context 'when default configuration is loaded' do
    config = Config.load('example.config.yml')

    it 'should not be empty' do
      expect(config).to_not be_empty
    end

    it 'returns keys as symbols' do
      config.each { |k, _| expect(k).to be_a(Symbol) }
    end
  end
end
