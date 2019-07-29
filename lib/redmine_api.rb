require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'yaml'

class RedmineApi

  def initialize(config)
    load_config(config)
  end

  def add_time(entry)
    uri = URI.parse(@config['server']['url'] + '/time_entries.json')
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    header = {
        'Content-Type' =>'application/json',
        'X-Redmine-API-Key' => @config['server']['apikey']
    }
    request = Net::HTTP::Post.new(uri.path, header)

    entry_dto = {
      'time_entry' => {
        'issue_id' => entry[:issue],
        'spent_on' => entry[:date],
        'hours' => entry[:time],
        'activity_id' => @config['activities'][entry[:activity]],
        'comments' => entry[:text]
      }
    }

    request.body = entry_dto.to_json
    result = https.request(request)
    result.body.force_encoding('utf-8')

    unless result.code == '201'
      warn "Fehler beim Buchen (#{@config['name']}): #{result.message}, Rückgabe #{result.body}"
      return false
    end

    true
  end

  def valid_activity?(activity)
    @config['activities'].key? activity
  end

  def get_issue(issue_id)
    uri = URI.parse(@config['server']['url'] + '/issues/' + issue_id.to_s + '.json')
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    header = {
        'Content-Type' =>'application/json',
        'X-Redmine-API-Key' => @config['server']['apikey']
    }
    request = Net::HTTP::Get.new(uri.path, header)
    result = https.request(request)
    result.body.force_encoding('utf-8')

    issue = JSON.parse(result.body)
    unless result.code == '200'
      raise "Fehler beim Laden des Issues (\##{issue_id}): #{result.message}, Rückgabe #{result.body}"
    end

    issue['issue']['subject']
  end

  private

  def load_config(config)
    raise "Fehler: Redmine API-Key nicht gesetzt" if config['server']['apikey'].nil?

    activities = {}
    config['activities'].each do |id, aliases|
      aliases.each do |name|
        activities[name] = id
      end
    end
    config['activities'] = activities

    @config = config
  end
end
