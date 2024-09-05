namespace :daily_guess_word do
  desc "Generate daily word game for a subject for the date range"
  # example usage for subject Biology 0610
  # rake daily_challenge:generate subject_code=0610 from_date=2024-05-20 to_date=2024-05-31 attempts=6 reward_points=1
  # rake daily_challenge:generate word_game_pool_id=xxx from_date=2024-05-20 to_date=2024-05-31
  task generate: :environment do
    # subject
    subject_code = ENV.fetch('subject_code', nil)
    pool_id = ENV.fetch('pool_id', nil)

    # config
    attempts = ENV.fetch('attempts', 6)
    reward_points = ENV.fetch('reward_points', 1)

    # date range
    from_date = ENV.fetch('from_date', nil)&.to_date || (Time.now + 1.day).to_date
    to_date = ENV['to_date'].to_date
    date_range = from_date..to_date

    if subject_code.present?
      subject = Subject.find_by!(code: subject_code)
      pool = GuessWordPool.find_by!(subject: subject, default_pool: true)
    elsif pool_id.present?
      pool = GuessWordPool.find_by!(id: pool_id)
    else
      raise "Please provide either subject_code or pool_id"
    end
    puts "Selected pool '#{pool.title}' for subject '#{pool.subject.name}' with #{pool.guess_word_questions.count} questions"

    progress_bar = ProgressBar.create(total: date_range.count, format: "%t: |%B| %p%% %e")
    dates = date_range.to_enum

    # Create a new enumerator to pull questions from
    questions = Enumerator.new do |enumerator|
      # Loop to create an endless question pool
      loop do
        # Find questions in small batches
        pool.guess_word_questions.find_in_batches(batch_size: 1000) do |questions|
          questions.shuffle.each do |question|
            enumerator << question
          end
        end
      end
    end

    ActiveRecord::Base.transaction do
      questions.zip(dates) do |question, date|
        break if date.blank?

        GuessWord.create!(
          subject: subject,
          answer: question.word,
          description: question.description,
          attempts: attempts,
          reward_points: reward_points,
          guess_word_pool_id: pool.id,
          start_at: date.beginning_of_day,
          end_at: date.end_of_day,
        )

        progress_bar.increment
      end
    end

    puts "Daily guess word generated for subject #{pool.subject.name} using #{pool.title} from #{from_date} to #{to_date}"
    puts "Generated #{date_range.count} questions from #{pool.guess_word_questions.count} pool questions"
  end
end
