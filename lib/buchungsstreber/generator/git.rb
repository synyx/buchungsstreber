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
      memo << `find "#{basedir}" -maxdepth 5 -name .git -a -type d -print0`.split("\0")
    end.flatten.sort.uniq
    git_dirs.each do |dir|
      gitlog = `git --git-dir "#{dir}" log --committer=#{user} --after="#{d1}" --before="#{d2}" --pretty=oneline --all`
      gitlog.lines.each do |line|
        hash, subject = line.split(/ /, 2)
        commit = `git --git-dir "#{dir} cat-file -p #{hash}`
        issue = case commit
                when /(?:fix|ref|close|see).*#(\d{3,})/
                  $1
                when /(?:branch|into) '(?:(\d{4,5})\D|[^']*\D(\d{4,5})')/
                  $1 || $2
                when /#(\d{4,5})(\W|$)/
                  $1 if $1.to_i > 6700
                else
                  nil
                end
        if issue
          entry = {
              date: date,
              issue: issue.to_i,
              text: subject.chomp,
          }
          entries << entry
        end
      end
    end

    entries
  end
end
