require 'buchungsstreber/generator/mention'

RSpec.describe Generator::Mention do
  context 'generation' do
    let(:config) { {} }
    let(:cmm) do
      <<EOS
~ possible mentions
31906	1.75	einhorn	Fehlersuche mit Jo	Bäng!
EOS
    end
    let(:result) do
      {
        comment: 'Mention from einhorn in project Bäng!',
        date: 'today',
        issue: '31906',
        text: 'Fehlersuche mit Jo',
        time: 1.75,
      }
    end

    subject { described_class.new(config) }
    before { allow(subject).to receive(:`).and_return(cmm) }

    it 'executes' do
      expect(subject.generate('today')).to include(result)
    end
  end
end
