#!/usr/bin/ruby

require "yaml"
require "colorize"
require "date"
require "fileutils"
require_relative "lib/validator"
require_relative "lib/parser"
require_relative 'lib/parser/yaml_timesheet'
require_relative 'lib/parser/buch_timesheet'
require_relative "lib/redmine_api"
require_relative "lib/utils"
require_relative "lib/redmines"
require_relative 'lib/config'

VERSION = "1.1.0"

config = Config.load

timesheet_file = File.expand_path(config["timesheet_file"], __dir__)
timesheet_parser = TimesheetParser.new timesheet_file, config["templates"]
redmines = Redmines.new(config["redmines"])

entries = timesheet_parser.parse

title = "BUCHUNGSSTREBER v#{VERSION}"
puts title.bold
puts "~" * title.length
puts ""

puts "Buchungsübersicht:".bold
validator = Validator.new
daily_hours = Hash.new(0)
valid = true
entries.each do |entry|
  redmine = redmines.get(entry[:redmine])
  valid &= validator.validate(entry, redmine)
  daily_hours[entry[:date]] += entry[:time]

  weekday = entry[:date].strftime("%a")
  print "#{weekday}: "
  time_s = (entry[:time].to_s + "h").ljust(5)
  print time_s.bold
  print " @ "
  issue_title = Utils.fixed_length(redmine.get_issue(entry[:issue]), 50)
  print issue_title.blue
  print ": "
  text = Utils.fixed_length(entry[:text], 30)
  puts text
end
puts ""

unless valid
  puts "Ungültige Buchungen gefunden – Abbruch!".red.bold
  exit
end

min_date, max_date = daily_hours.keys.minmax
puts "Zu buchende Stunden (#{min_date} bis #{max_date}):".bold
daily_hours.each do |date, hours|
  if hours < 4 || hours > 12
    color = :red
  elsif hours < 7 || hours > 9
    color = :yellow
   else
     color = nil
  end
  puts "#{date.strftime("%a")}: #{hours}".colorize(color)
end

puts "Buchungen in Redmine übernehmen? (j/N)"
cont = gets.chomp
unless cont == "j" || cont == "y"
  puts "Abbruch"
  exit
end

entries.each do |entry|
  puts "Buche #{entry[:time]}h auf \##{entry[:issue]}: #{entry[:text]}"
  success = redmines.get(entry[:redmine]).add_time entry
  puts success ? "→ OK".green : "→ FEHLER".red.bold
end

puts "Buchungen erfolgreich gespeichert".green.bold

archive_path = File.expand_path(config["archive_path"], __dir__)
timesheet_parser.archive(archive_path, min_date)
