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
  end

  context 'Configured buchungsstreber' do
    before(:all) { set_environment_variable('EDITOR', 'cat') }
    before(:each) do
      run_command('buchungsstreber init')
      expect(last_command_started).to be_successfully_executed
    end

    it 'runs config command' do
      run_command('buchungsstreber config')
      expect(last_command_started).to have_output(/^timesheet_file:/)
      expect(last_command_started).to be_successfully_executed
    end

    it 'runs edit command' do
      FileUtils.copy(example_file, entry_file)
      run_command('buchungsstreber edit')
      expect(last_command_started).to have_output(/BeispielDaily/)
      expect(last_command_started).to be_successfully_executed
    end

    it 'adds times to redmine' do
      port = rand(10000) + 10000
      config = YAML.load_file(config_file)
      config['redmines'].each do |r|
        r['server']['url'] = "http://localhost:#{port}"
        r['server']['apikey'] = port.to_s
      end

      File.open(config_file, 'w+') do |o|
        YAML.dump(config, o)
      end
    end
  end
end
