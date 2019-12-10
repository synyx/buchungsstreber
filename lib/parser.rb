# TimesheetParser selects the correct parser depending on the extension.
class TimesheetParser
  PARSERS = []

  def initialize(file, templates)
    @file = file
    @parser = choose_parser(file).new(templates)
  end

  def parse
    @parser.parse(@file)
  end

  def archive(archive_path, date)
    @parser.archive(@file, archive_path, date)
  end

  private

  def choose_parser(file)
    parser = PARSERS.find { |p| p.respond_to?(:parses?) and p.parses?(file) }
    parser or throw "Unknown file extension, cannot parse #{file}"
  end

  module Base
    def self.extended(klass)
      PARSERS << klass
    end
  end
end
