require 'rspec'

require 'buchungsstreber/config'
require 'buchungsstreber/generator/redmine_time_entries'

RSpec.describe Buchungsstreber::Generator::RedmineTimeEntries do
  let(:config_file) { File.expand_path('../../example.config.yml', __dir__) }
  let(:config) { Buchungsstreber::Config.load(config_file) }
  let(:result) do
    {
      :activity => "Organisation",
      :date => Date.today,
      :id => 208590,
      :issue => 39665,
      :redmine => "S",
      :text => "Selbstorganisation, E-Mails, Nachrichten",
      :time => 0.5,
    }
  end
  let(:time_entries) do
    {
      "time_entries": [
        {
          "id": 208590,
          "project": {
            "id": 10,
            "name": "example"
          },
          "issue": {
            "id": 39665
          },
          "user": {
            "id": 343,
            "name": "Test"
          },
          "activity": {
            "id": 12,
            "name": "Organisation"
          },
          "hours": 0.5,
          "comments": "Selbstorganisation, E-Mails, Nachrichten",
          "spent_on": "2022-04-25",
          "created_on": "2022-04-25T06:00:30Z",
          "updated_on": "2022-04-25T06:00:30Z",
          "custom_fields": [
            {
              "id": 3,
              "name": "Mehraufwand",
              "value": "nein"
            },
            {
              "id": 8,
              "name": "vor Ort?",
              "value": ""
            }
          ]
        }
      ]
    }
  end

  context 'generation' do
    it 'extracts a time entry from existing one in redmine' do
      generator = described_class.new(config)
      today = Date.today
      get_times_stub = stub_request(:get, "https://project.synyx.de/time_entries.json?from=#{today}&to=#{today}&user_id=me")
                         .to_return(status: 200, body: JSON.dump(time_entries))
      get_times_stub2 = stub_request(:get, "https://projects.example.net/time_entries.json?from=#{today}&to=#{today}&user_id=me")
                          .to_return(status: 200, body: JSON.dump({ 'time_entries' => [] }))

      expect(generator.generate(today)).to include(result)

      expect(get_times_stub).to have_been_requested.at_least_once
      expect(get_times_stub2).to have_been_requested.at_least_once
    end
  end
end
