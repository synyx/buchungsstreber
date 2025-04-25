require 'rspec'

require 'buchungsstreber/redmine_api'

RSpec.describe Buchungsstreber::RedmineApi do
  let(:config_file) { File.expand_path('../example.config.yml', __dir__) }

  subject do
    config = Buchungsstreber::Config.load(config_file)
    config[:redmines].each do |r|
      r['server']['apikey'] = 'asdf'
    end

    described_class.new(config[:redmines][0])
  end

  context 'when getting an issue' do
    it 'succeeds normally' do
      get_times_stub = stub_request(:get, "https://project.synyx.de/issues/1234.json")
                           .to_return(status: 200, body: JSON.dump({ 'issue' => {'id' => 1234} }))

      subject.get_issue('1234')

      expect(get_times_stub).to have_been_requested.at_least_once
    end

    it 'raises an error on bad json' do
      get_times_stub = stub_request(:get, "https://project.synyx.de/issues/1234.json")
                           .to_return(status: 200, body: '<html></html>')

      expect { subject.get_issue('1234') }.to raise_error(/unexpected/)

      expect(get_times_stub).to have_been_requested.at_least_once
    end

    it 'raises an error on anything other than 200' do
      get_times_stub = stub_request(:get, "https://project.synyx.de/issues/1234.json")
                           .to_return(status: 500, body: '<html></html>')

      expect { subject.get_issue('1234') }.to raise_error(/Unexpected result code/)

      expect(get_times_stub).to have_been_requested.at_least_once
    end
  end
end
