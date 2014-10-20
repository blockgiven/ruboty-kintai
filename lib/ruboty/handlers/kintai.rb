module Ruboty
  module Handlers
    class Kintai < Base
      NAMESPACE = 'kintai'

      on /(?:ｼｭｯｼｬ|出社|出勤|帰りたい)(?:@(?<go_work_at>.*))?/, name: 'go_work', description: '出社時間を記録'
      on /(?:ﾀｲｼｬ|退社|退勤|帰る)(?:@(?<go_home_at>.*))?/,     name: 'go_home', description: '退社時間を記録'
      on /(?:kintai|勤怠) ?(?<start>.*)から(?<end>.*)まで(?<reporter>csv)?/,   name: 'list',    description: '勤怠を見る'

      def go_work(message)
        go_work_at = Time.parse((message[:go_work_at] || Time.now).to_s)

        kintai[message.from_name] ||= {}
        kintai[message.from_name][:go_work_at] = go_work_at

        greedings = %w(おはよー はよ はよはよ やっほー ふゎあぁ、おはよ ...)

        message.reply("#{greedings.sample}, #{message.from_name}.")
      rescue => e
        if /no time information in/ =~ e.message
          message.reply('時間がわからへん')
        else
          message.reply(e.message)
        end
      end

      def go_home(message)
        go_home_at = Time.parse((message[:go_home_at] || Time.now).to_s)

        kintai[message.from_name] ||= {}
        kintai[message.from_name][:go_home_at] = go_home_at

        greedings = %w(おつかれさま おつかれさん 乙 はなきんだー バイバイ!)

        if work_time = work_time(go_home_at, message.from_name)
          stats = "今日は#{work_time}働いたみたいだよ。お疲れ様でした。"
        else
          stats = %w(あれ、いつきたのかな? 日付かわっちゃったかな? あ、帰る前に何時にきたか教えて!).sample
        end
        message.reply("#{greedings.sample}, #{message.from_name}. #{stats}.")
      rescue => e
        if /no time information in/ =~ e.message
          message.reply('時間がわからへん')
        else
          message.reply(e.message)
        end
      end

      def list(message)
        start_at = message[:start].tr('０-９', '0-9').gsub(/ヶ月|ケ月|か月|ヵ月|カ月/, '月')
        start_at = (Tokiyomi.parse(start_at) rescue Time.parse(start_at))
        end_at   = message[:end].tr('０-９', '0-9').gsub(/ヶ月|ケ月|か月|ヵ月|カ月/, '月')
        end_at   = (Tokiyomi.parse(end_at) rescue Time.parse(end_at))

        reporter = reporter_for(message)
        message.reply(reporter.new(kintai_range(start_at, end_at)).report)
      rescue => e
        message.reply("ごめんな、勤怠わからへん: #{e.message}@#{e.backtrace.take(5).join($/)}")
      end

      # こんな感じ
      # {
      #   '2014-01-02': {
      #     'blockgiven': {
      #       go_home_at: Time.now,
      #       go_work_at: Time.now
      #     }
      #   }
      # }
      def kintai(now = Time.now)
        robot.brain.data[NAMESPACE] ||= {}
        robot.brain.data[NAMESPACE][now.strftime("%Y-%m-%d")] ||= {}
      end

      def kintai_range(start_at, end_at)
        Enumerator.new {|y|
          time = start_at
          while time < end_at.end_of_day do
            y << [time.beginning_of_day, kintai(time)]
            time = time.tomorrow
          end
        }
      end

      def work_time(time, name)
        go_work_at = kintai(time).fetch(name, {})[:go_work_at]
        go_home_at = kintai(time).fetch(name, {})[:go_home_at]

        if go_work_at and go_home_at
          Time.at(go_home_at - go_work_at - 9.hours).strftime("%H:%M") # FIXME
        end
      end

      def reporter_for(message)
        case message[:reporter]
        when /csv/i
          Ruboty::Kintai::Reporters::Csv
        else
          raise 'csv以外は出力できへん'
        end
      end
    end
  end
end
