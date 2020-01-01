class Generator::Git
  include Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    entries = []
    d = date.to_s
    d1 = `date -d "#{d}" -R`.chomp
    d2 = `date -d "#{d} +1 day" -R`.chomp

    user = ENV['USER']

    git_dirs = @config[:dirs].each_with_object([]) do |basedir, memo|
      memo << `find #{basedir} -maxdepth 5 -name .git -a -type d -print0`.split("\0")
    end.flatten.sort.uniq
    git_dirs.each do |dir|
      gitlog = `git --git-dir #{dir} log --committer=#{user} --after="#{d1}" --before="#{d2}" --pretty=oneline --all`
      gitlog.lines.each do |line|
        hash, subject = line.split(/ /, 2)
        commit = `git --git-dir #{dir} cat-file -p #{hash}`
        if commit =~ /(?:fix|ref|close).*#(\d{3,})/
          entry = {
              date: date,
              issue: $1.to_i,
              text: subject.chomp,
          }
          entries << entry
        end
      end
    end

    entries
  end
end
