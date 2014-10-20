module Ruboty
  module Kintai
    module Reporters
      class Csv
        def initialize(kintai_range)
          @kintai_range = kintai_range
        end

        def report
          CSV.generate do |csv|
            csv << %w(日付 名前 出勤 退勤)
            @kintai_range.each do |time, kintais|
              if kintais.empty?
                csv << [time.strftime("%Y-%m-%d"), "", "", ""]
                next
              end

              kintais.each do |name, kintai|
                csv << [time.strftime("%Y-%m-%d"), name, kintai[:go_work_at], kintai[:go_home_at]]
              end
            end
          end
        end
      end
    end
  end
end
