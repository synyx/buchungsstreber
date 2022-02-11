require 'buchungsstreber/generator/xchat'

RSpec.describe Buchungsstreber::Generator::XChat do
  let(:config) { {} }
  let(:command_output) do
    <<EOS
~ possible ticket NRs
13:37:20 [#channel] <buch> https://projects.example.com/issues/22222
13:37:20 [#channel] <buch> check #22224
EOS
  end
  let(:result) do
    [{
      comment: '13:37:20 [#channel] <buch> https://projects.example.com/issues/22222',
      date: 'today',
      issue: 22222,
    },{
      comment: '13:37:20 [#channel] <buch> check #22224',
      date: 'today',
      issue: 22224,
    }]
  end

  context 'generation' do
    subject { described_class.new(config) }
    before { allow(subject).to receive(:`).and_return(command_output) }

    it 'executes' do
      expect(subject.generate('today')).to contain_exactly(*result)
    end
  end

  context 'no mentions' do
    subject { described_class.new(config) }
    before { allow(subject).to receive(:`).and_return("asdf\nasdf\n") }

    it 'executes' do
      expect(subject.generate('today').compact).to be_empty
    end
  end
end
