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
    post("/time_entries.json", entry_dto)
  end

  def valid_activity?(activity)
    @config["activities"].key? activity
  end

  def get_issue(issue_id)
    get("/issues/#{issue_id}") do |issue|
      issue["issue"]["subject"]
    end
  end

  private

  def post(path, dto)
    uri = URI.parse(@config["server"]["url"] + path + ".json")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    header = {
        "Content-Type" =>"application/json",
        "X-Redmine-API-Key" => @config["server"]["apikey"]
    }
    request = Net::HTTP::Post.new(uri.path, header)
    request.body = dto.to_json
    result = https.request(request)
    result.body.force_encoding("utf-8")

    unless result.code == "201"
      warn "Fehler bei POST (#{@config["name"]}): #{result.message}, Rückgabe #{result.body}"
      return false
    end

    true
  end

  def get(path)
    uri = URI.parse(@config["server"]["url"] + path + ".json")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    header = {
        "Content-Type" =>"application/json",
        "X-Redmine-API-Key" => @config["server"]["apikey"]
    }
    request = Net::HTTP::Get.new(uri.path, header)
    result = https.request(request)
    result.body.force_encoding("utf-8")

    body = JSON.parse(result.body)
    unless result.code == "200"
      raise "Fehler beim Laden des Issues (\##{issue_id}): #{result.message}, Rückgabe #{result.body}"
    end

    yield body
  rescue JSON::ParserError => e
    raise "Fehler beim Laden des Issues (\##{issue_id}): #{e}, Rückgabe #{result.body}"
  end

  private

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
