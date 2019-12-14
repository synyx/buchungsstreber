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
      run_command('buchungsstreber version')
      expect(last_command_started).to be_successfully_executed
      expect(last_command_started).to have_output(/\d+\.\d+/)
    end

    it 'runs init command' do
      run_command('buchungsstreber init')
      expect(last_command_started).to be_successfully_executed
      expect(last_command_started).to have_output(/erstellt/)
      expect(config_file).to be_an_existing_file
    end

    it 'does nothing when running config' do
      run_command('buchungsstreber config')
      expect(last_command_started).to have_output(/Error/)
      expect(last_command_started).to_not be_successfully_executed
    end

    it 'does nothing when running edit' do
      run_command('buchungsstreber edit')
      expect(last_command_started).to have_output(/Error/)
      expect(last_command_started).to_not be_successfully_executed
    end

    it 'does nothing when running execute' do
      run_command('buchungsstreber execute --debug')
      expect(last_command_started).to have_output(/Error/)
      expect(last_command_started).to_not be_successfully_executed
    end
  end

  context 'Configured buchungsstreber' do
    before(:each) do
      run_command('buchungsstreber init')
      expect(last_command_started).to be_successfully_executed

      # Make sure the api-keys are set
      run_command('buchungsstreber config')
      expect(last_command_started).to be_successfully_executed
      config = YAML.load(last_command_started.stdout)
      config['redmines'].each do |r|
        r['server']['url'] = 'https://localhost'
        r['server']['apikey'] = 'anything'
      end
      File.open(config_file, 'w+') { |io| YAML.dump(config, io) }
    end

    entry = {
      Date.today => ['0.25   Orga    S8484   Blog']
    }
    issue_8484 = {
      "issue" => {
        "subject" => "Blog",
      }
    }
    it 'does not allow a second run to init' do
      run_command('buchungsstreber init')
      expect(last_command_started).to have_output(/bereits konfiguriert/)
    end

    it 'runs config command' do
      run_command('buchungsstreber config')
      expect(last_command_started).to have_output(/^timesheet_file:/)
      expect(last_command_started).to have_output(/url: htt/)
      expect(last_command_started).to have_output(/apikey: anything/)
      expect(last_command_started).to be_successfully_executed
    end

    it 'runs edit command' do
      FileUtils.copy(example_file, entry_file)
      run_command('buchungsstreber edit')
      expect(last_command_started).to have_output(/BeispielDaily/)
      expect(last_command_started).to be_successfully_executed
    end

    it 'adds times to redmine' do
      validation_stub = stub_request(:get, "https://localhost/issues/8484.json").
        to_return(status: 200, body: JSON.dump(issue_8484))
      add_time_stub = stub_request(:post, "https://localhost/time_entries.json").
        to_return(status: 201)

      File.open(entry_file, 'w+') { |io| YAML.dump(entry, io) }
      c = run_command('buchungsstreber execute')
      expect(c).to have_output(/BUCHUNGSSTREBER/)

      expect(validation_stub).to have_been_requested.at_least_once
      expect(add_time_stub).to have_been_requested.at_least_once
    end
  end
end
