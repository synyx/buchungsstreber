SimpleCov.command_name "buchungsstreber"
SimpleCov.root(__dir__)

SimpleCov.start

SimpleCov.configure do
  filters.clear
  load_profile "bundler_filter"
  load_profile "hidden_filter"
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}/)
  end

  # Changed Files in Git Group
  # @see http://fredwu.me/post/35625566267/simplecov-test-coverage-for-changed-files-only
  untracked         = `git ls-files --exclude-standard --others -z`
  unstaged          = `git diff --name-only -z`
  staged            = `git diff --name-only --cached -z`
  changed_filenames = [untracked, unstaged, staged].map { |x| x.split("\x0") }.flatten

  unless changed_filenames.empty?
    add_group 'Changed' do |source_file|
      changed_filenames.find { |x| source_file.filename.end_with?(x) }
    end
  end

  add_group 'Specs', 'spec'
  add_group 'Libraries', 'lib'
end
