require 'yaml'

RSpec.describe 'CLI App', type: :aruba do
  let(:config_file) { expand_path('~/.config/buchungsstreber/config.yml') }
  let(:entry_file) { expand_path('~/.config/buchungsstreber/buchungen.yml') }
  let(:archive_path) { expand_path('~/.config/buchungsstreber/archive') }
  let(:example_file) { File.expand_path('../example.buchungen.yml', __dir__) }

  context 'Aruba' do
    it { expect(aruba).to be }
  end

  context 'Unconfigured buchungsstreber' do
    it 'runs version command' do
      run_command_and_stop('buchungsstreber version')
      expect(last_command_started).to have_output(/\d+\.\d+/)
    end

    it 'runs init command' do
      run_command_and_stop('buchungsstreber init --debug')
      expect(last_command_started).to have_output(/erstellt/)
      expect(config_file).to be_an_existing_file
    end

    %w[config edit execute show].each do |cmd|
      it "does nothing when running #{cmd}" do
        run_command_and_stop("buchungsstreber #{cmd} --debug", fail_on_error: false)
        expect(last_command_started).to have_output(/Error|Fehler/i)
        expect(last_command_started).to_not be_successfully_executed
      end
    end
  end

  context 'Configured buchungsstreber' do
    entry = {
      Date.today => ['0.25   Orga    S8484   Blog']
    }
    issue8484 = {
      "issue" => {
        "subject" => "Blog",
      }
    }
    current_user = {
        'user' => {
            'id' => 1,
        }
    }

    before(:each) do
      run_command_and_stop('buchungsstreber init')

      # Make sure the api-keys are set
      run_command_and_stop('buchungsstreber config')
      config = YAML.safe_load(last_command_started.stdout)
      config['redmines'].each do |r|
        r['server']['url'] = 'https://localhost'
        r['server']['apikey'] = 'anything'
      end
      config['generators'] = {}
      config['generators']['mock'] = {}
      config['resolvers'] = {}
      config['resolvers']['mock'] = {}
      File.open(config_file, 'w+') { |io| YAML.dump(config, io) }
      File.open(entry_file, 'w+') { |io| YAML.dump(entry, io) }
    end

    it 'does not allow a second run to init' do
      run_command_and_stop('buchungsstreber init')
      expect(last_command_started).to have_output(/bereits konfiguriert/)
      expect(last_command_started).to_not have_output(/erstellt/)
    end

    it 'runs config command' do
      run_command_and_stop('buchungsstreber config')
      expect(last_command_started).to have_output(/^timesheet_file:/)
      expect(last_command_started).to have_output(/url: htt/)
      expect(last_command_started).to have_output(/apikey: anything/)
    end

    it 'runs edit command' do
      FileUtils.copy(example_file, entry_file)
      run_command_and_stop('buchungsstreber edit --debug')
      expect(last_command_started).to have_output(/BeispielDaily/)
    end

    it 'runs edit with date command' do
      FileUtils.copy(example_file, entry_file)
      run_command_and_stop("buchungsstreber edit --debug #{Date.today.iso8601}")
      expect(last_command_started).to have_output(/generated/)
      expect(last_command_started).to have_output(/resolved/)
    end

    it 'runs show command' do
      stub_request(:get, "https://localhost/issues/8484.json").to_return(status: 200, body: JSON.dump(issue8484))

      run_command_and_stop("buchungsstreber show --debug #{Date.today.iso8601}")
      expect(last_command_started).to have_output(/Blog/)
    end

    it 'adds times to redmine' do
      today = Date.today
      validation_stub = stub_request(:get, "https://localhost/issues/8484.json")
                        .to_return(status: 200, body: JSON.dump(issue8484))
      user_stub = stub_request(:get, "https://localhost/users/current.json")
                  .to_return(status: 200, body: JSON.dump(current_user))
      get_times_stub = stub_request(:get, "https://localhost/time_entries.json?from=#{today}&to=#{today}&user_id=1")
                       .to_return(status: 200, body: JSON.dump({ 'time_entries' => [] }))
      add_time_stub = stub_request(:post, "https://localhost/time_entries.json")
                      .to_return(status: 201)

      run_command_and_stop('buchungsstreber execute --debug')
      expect(last_command_started).to have_output(/BUCHUNGSSTREBER/)

      expect(validation_stub).to have_been_requested.at_least_once
      expect(user_stub).to have_been_requested.at_least_once
      expect(get_times_stub).to have_been_requested.at_least_once
      expect(add_time_stub).to have_been_requested.at_least_once
    end
  end
end

class Generator::Mock
  include Generator::Base

  def initialize(_config)
    # ignored
  end

  def generate(date)
    [
      {
          date: date,
          time: 0.5,
          activity: 'Dev',
          text: 'generated',
      },
      {
          date: date,
          time: 0.5,
          activity: 'BeispielDaily',
      }
    ]
  end
end

class Resolver::Mock
  include Resolver::Base


  def initialize(config)
    @config = config
  end

  def resolve(entry)
    entry[:text] ||= ''
    entry[:text] += ' resolved'
    entry
  end
end
