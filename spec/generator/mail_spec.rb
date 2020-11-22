require 'buchungsstreber/generator/mail'

RSpec.describe Generator::Mail do
  let(:config) { {} }
  let(:command_output) do
    <<EOS

Searching mails for 14-Oct-2020
< To: a@example.com>
< Subject: Baaar Foo
< Subject: Re: Baaar Foo
< To: Nada <a@example.com>>
< Subject: Re: Baaar Foo
< To: Foooo <a@example.com>
EOS
  end
  let(:result) do
    {
      comment: 'Mail: Baaar Foo',
      date: 'today',
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
