require 'buchungsstreber/generator/ncalcli'

RSpec.describe Buchungsstreber::Generator::NCalCLI do
  let(:config) { { "ignore" => "Mittagspause" } }
  let(:command_output) do
    <<EOS
Fri 18.09\t10:30\t1.0\tBuchungsstreber-Hacksession
Fri 18.09\t12:30\t2.0\tHunderunde / Mittagspause
EOS
  end
  let(:result) do
    {
        date: '2020-09-18',
        issue: nil,
        text: 'Buchungsstreber-Hacksession',
        time: 1.0,
    }
  end
  let(:no_result) do
    {
        date: '2020-09-18',
        issue: nil,
        text: 'Mittagspause',
        time: 2.0,
    }
  end

  context 'generation' do
    subject { described_class.new(config) }
    before { allow(subject).to receive(:`).and_return(command_output) }

    it 'executes' do
      expect(subject.generate('2020-09-18')).to include(result)
      expect(subject.generate('2020-09-18')).not_to include(no_result)
    end
  end
end
