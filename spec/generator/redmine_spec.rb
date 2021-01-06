require 'buchungsstreber/generator/redmine'

RSpec.describe Buchungsstreber::Generator::Redmine do
  let(:config) { [
      {
        url: 'https://project.example.com',
        uid: 42,
        rsskey: 23456789,
        redmine: 's',
      }
  ] }
  let(:command_output) do
    <<EOS
~ https://project.example.com Redmine
  Admin - Task #39665: Things
EOS
  end
  let(:result) do
    {
      comment: 'Admin Things',
      date: 'today',
      issue: '39665',
      redmine: 's',
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
