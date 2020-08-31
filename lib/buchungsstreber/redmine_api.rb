require "uri"
require "net/http"
require "net/https"
require "json"
require "yaml"

class RedmineApi

  def initialize(config)
    load_config(config)
  end

  def add_time(entry)
    entry_dto = {
      "time_entry" => {
        "issue_id" => entry[:issue],
        "spent_on" => entry[:date],
        "hours" => entry[:time],
        "activity_id" => @config["activities"][entry[:activity]],
        "comments" => entry[:text]
      }
    }
    post("/time_entries", entry_dto)
  end

  def valid_activity?(activity)
    @config["activities"].key? activity
  end

  def same_activity?(a, b)
    valid_activity?(a) and valid_activity?(b) and @config["activities"][a] == @config["activities"][b]
  end

  def get_issue(issue_id)
    get("/issues/#{issue_id}") do |issue|
      issue["issue"]["subject"]
    end
  end

  def get_times(day)
    get("/time_entries", from: day.to_s, to: day.to_s, user_id: user_id) do |time_entries|
      time_entries['time_entries'].map do |entry|
        from_time_entry(entry)
      end
    end
  end

  def get_time(id)
    get("/time_entries/#{id}") do |entry|
      from_time_entry(entry['time_entry'])
    end
  end

  def prefix
    @config['prefix'].dup
  end

  private

  def user_id
    @user_id ||= get("/users/current") { |u| u['user']['id'] }
  end

  def post(path, dto)
    uri = URI.parse(@config["server"]["url"] + path + ".json")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    header = {
      "Content-Type" => "application/json",
      "X-Redmine-API-Key" => @config["server"]["apikey"]
    }
    request = Net::HTTP::Post.new(uri, header)
    request.body = dto.to_json
    result = https.request(request)
    result.body.force_encoding("utf-8")

    unless result.code == "201"
      warn "Fehler bei POST (#{@config["name"]}): #{result.message}, Rückgabe #{result.body}"
      return false
    end

    true
  end

  def get(path, params = nil)
    uri = URI.parse(@config["server"]["url"] + path + ".json")
    uri.query = URI.encode_www_form(params) if params
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    header = {
      "Content-Type" => "application/json",
      "X-Redmine-API-Key" => @config["server"]["apikey"]
    }
    request = Net::HTTP::Get.new(uri, header)
    result = https.request(request)
    result.body.force_encoding("utf-8")

    body = JSON.parse(result.body)
    unless result.code == "200"
      raise "Fehler beim Laden (#{path}): #{result.message}, Rückgabe #{result.body}"
    end

    (yield body if block_given?) || body
  rescue JSON::ParserError => e
    raise "Fehler beim Laden des Issues (\##{issue_id}): #{e}, Rückgabe #{result.body}"
  end

  private

  def from_time_entry(entry)
    possible_activities = @config['activities'].select { |x, y| y == entry['activity']['id'] }
    # use shortest one for displaying
    activity = possible_activities.to_a.sort { |x| x[0].length }[0][0]
    {
      id: entry['id'],
      issue: entry['issue']['id'],
      date: Date.parse(entry['spent_on']),
      time: entry['hours'],
      activity: activity.freeze,
      text: entry['comments'].freeze,
    }
  end

  def load_config(config)
    raise "Fehler: Redmine API-Key nicht gesetzt" if config["server"]["apikey"].nil?

    activities = {}
    config["activities"].each do |id, aliases|
      aliases.each do |name|
        activities[name] = id
      end
    end
    config = config.dup
    config["activities"] = activities

    @config = config
  end
end
