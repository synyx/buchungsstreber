require 'buchungsstreber/resolver/regexp'

RSpec.describe Resolver::Regexp do
  let(:config) do
    [ { 're' => 'bei Tiffany',
        'entry' => {
          'activity' => 'Orga',
          'issue' => 6325,
          'redmine' => 'S',
          'text' => 'Frühstück',
    } } ]
  end

  let(:entry) do
    {
        date: "2020-10-02",
        time: 2.0,
        text: 'Frühstück bei Tiffany',
        issue: nil,
    }
  end

  let(:result) do
    {
        date: "2020-10-02",
        time: 2.0,
        text: 'Frühstück',
        issue: 6325,
        redmine: 'S',
        activity: 'Orga'
    }
  end

  context 'resolution' do
    subject { described_class.new(config) }

    it 'executes' do
      expect(subject.resolve(entry)).to include(result)
    end
  end
end
