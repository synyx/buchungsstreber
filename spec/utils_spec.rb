require 'buchungsstreber/utils'

RSpec.describe Utils, '#classify_workhours' do

  context 'when being overworked' do
    it 'return :red when worked over 4 hours more or less' do
      color = Utils.classify_workhours(3.9, hours: 8)
      expect(color).to eq(:red)
    end

    it 'return :yellow when worked up to 4 hours more or less' do
      color = Utils.classify_workhours(6.9, hours: 8)
      expect(color).to eq(:yellow)
    end
  end
end
