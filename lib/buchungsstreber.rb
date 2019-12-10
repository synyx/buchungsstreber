#!/usr/bin/ruby

require "yaml"
require "rainbow/refinement"
require "date"
require "fileutils"

require_relative 'buchungsstreber/aggregator'
require_relative 'buchungsstreber/version'
require_relative 'buchungsstreber/validator'
require_relative 'buchungsstreber/parser'
require_relative 'buchungsstreber/redmine_api'
require_relative 'buchungsstreber/utils'
require_relative 'buchungsstreber/redmines'
require_relative 'buchungsstreber/config'

VERSION = Buchungsstreber::VERSION

using Rainbow

config = Config.load

timesheet_file = File.expand_path(config[:timesheet_file], __dir__)
timesheet_parser = TimesheetParser.new(timesheet_file, config[:templates])
redmines = Redmines.new(config[:redmines])

entries = timesheet_parser.parse
entries = Aggregator.aggregate(entries)

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
  color = Utils.classify_workhours(hours, config)
  puts "#{date.strftime("%d.%m. (%a)")}: #{hours}".color(color)
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

archive_path = File.expand_path(config[:archive_path], __dir__)
timesheet_parser.archive(archive_path, min_date)
