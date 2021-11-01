require 'buchungsstreber/generator/git'

RSpec.describe Buchungsstreber::Generator::Git do
  let(:config) { { dirs: ['/work'] } }
  let(:command_outputs) do
    [
      'Mon, 01 Nov 2021 16:51:22 +0100',
      'Tue, 02 Nov 2021 16:51:39 +0100',
      "/work/dirA\0",
      'dab618e3d6f36835803846a446364f31214db0c8 (thing-2.1.x) reformat db changelog',
      <<EOS
tree ba45209ee8ad2d2a5fc710ce6062edab8ec47529
parent dab618e3d6f36835803846a446364f31214db0c8
author Jonathan Buch <jbuch@synyx.de> 1629979970 +0200
committer Jonathan Buch <jbuch@synyx.de> 1629979970 +0200

use varchar 200 instead of 120

* refs #44299
EOS
    ]
  end
  let(:result) do
    Buchungsstreber::Entry.new({
      date: 'today',
      issue: 44299,
      text: '(thing-2.1.x) reformat db changelog',
      time: 0,
    })
  end

  context 'generation' do
    subject { described_class.new(config) }
    before { allow(subject).to receive(:`).exactly(command_outputs.size).times.and_return(*command_outputs) }

    it 'executes' do
      expect(subject.generate('today')).to include(result)
    end
  end

end
