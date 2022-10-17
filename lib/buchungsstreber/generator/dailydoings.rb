class Buchungsstreber::Generator::DailyDoings
    include Buchungsstreber::Generator::Base

    def initialize(config)
        @dailydoings = config
    end

    def generate(date)

        dailydoings = @dailydoings

        p dailydoings

        Buchungsstreber::Entry.new(
            date: date,
            redmine: dailydoings[0]['redmine'],
            issue: dailydoings[0]['issue'],
            activity: dailydoings[0]['activity'],
            text: dailydoings[0]['text']
        )
    end

end
