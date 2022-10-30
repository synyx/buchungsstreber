class Buchungsstreber::Generator::DailyDoings
    include Buchungsstreber::Generator::Base

    def initialize(config)
        @dailydoings = config
    end

    def generate(date)

        dailydoings = @dailydoings

        p dailydoings

        dailydoings.map do |doing|
            Buchungsstreber::Entry.new(
                date: date,
                redmine: doing['redmine'],
                issue: doing['issue'],
                activity: doing['activity'],
                text: doing['text']
            )
        end

    end

end
