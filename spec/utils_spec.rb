require 'buchungsstreber/utils'

RSpec.describe Buchungsstreber::Utils, '#classify_workhours' do
  context 'when being overworked' do
    it 'return :red when worked over 4 hours more or less' do
      color = described_class.classify_workhours(3.9, 8)
      expect(color).to eq(:red)
    end

    it 'return :yellow when worked up to 4 hours more or less' do
      color = described_class.classify_workhours(6.9, 8)
      expect(color).to eq(:yellow)
    end
  end
end
