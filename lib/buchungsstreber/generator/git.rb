class Generator::Git
  include Generator::Base

  def generate(date)
    entries = []
    d = date.to_s
    d1 = `date -d "#{d}" -R`
    d2 = `date -d "#{d} +1 day" -R)`

    user = ENV['USER']

    git_dirs = config[:aggregator][:git][:dirs].each_with_object([]) do |basedir, memo|
      memo.union(`find #{basedir} -maxdepth 5 -name .git -a -type d -print0`.split("\0"))
    end
    git_dirs.each do |dir|
      gitlog = `git --git-dir #{dir} log --committer=#{user} --after="#{d1}" --before="#{d2}" --pretty=oneline --all`
      gitlog.each do |line|
        hash, subject = line.split(/ /, 2)
        commit = `git --git-dir #{dir} cat-file -p #{hash}`
        if commit =~ /(fix|ref|close).*#(\d{3,})/
          entry = Entry.new(0.0, date, nil, $1)
          entry.comment = commit
          entries << entry
        end
      end
    end

    entries
  end
end
