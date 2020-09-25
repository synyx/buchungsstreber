require 'buchungsstreber/generator/mention'

RSpec.describe Generator::Mention do
  let(:config) { {} }
  let(:command_output) do
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

  context 'generation' do
    subject { described_class.new(config) }
    before { allow(subject).to receive(:`).and_return(command_output) }

    it 'executes' do
      expect(subject.generate('today')).to include(result)
    end
  end

  context 'no mentions' do
    subject { described_class.new(config) }
    before { allow(subject).to receive(:`).and_return("asdf\nasdf\n") }

    it 'executes' do
      expect(subject.generate('today').compact).to eql([])
    end
  end
end
