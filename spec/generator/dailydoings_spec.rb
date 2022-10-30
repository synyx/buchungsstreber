require 'buchungsstreber/generator/dailydoings'

RSpec.describe Buchungsstreber::Generator::DailyDoings do
  let(:config) do 
    [ { 'activity' => 'Adm',
        'issue' => 7654,
        'redmine' => 's',
        'text' => 'Daily cleanup',
    } ]
  end

  let(:result) do
    {
      text: 'Daily cleanup',
      date: 'today',
      issue: 7654,
      redmine: 's',
      activity: 'Adm'
    }
  end

  context 'generation' do
    subject { described_class.new(config) }

    it 'executes' do
      expect(subject.generate('today')).to include(result)
    end
  end

end
