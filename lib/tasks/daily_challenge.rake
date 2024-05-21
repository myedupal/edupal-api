namespace :daily_challenge do
  desc "Generate daily challenge for a subject for the date range"
  # example usage for subject Biology 0610
  # rake daily_challenge:generate subject_code=0610 from_date=2024-05-20 to_date=2024-05-31 questions_per_challenge=10
  task generate: :environment do
    # subject
    subject = Subject.find_by!(code: ENV.fetch('subject_code', nil))

    # date range
    from_date = ENV['from_date'].to_date
    to_date = ENV['to_date'].to_date
    date_range = from_date..to_date

    # number of questions
    questions_per_challenge = ENV['questions_per_challenge'].to_i

    # get all the available questions for the subject
    questions = subject.questions.mcq.have_topics

    if questions.size < questions_per_challenge
      puts "Not enough questions available for the subject"
      return
    end

    progress_bar = ProgressBar.create(total: date_range.count, format: "%t: |%B| %p%% %e")
    ActiveRecord::Base.transaction do
      date_range.each do |date|
        # create daily challenge
        challenge = Challenge.create!(
          challenge_type: Challenge.challenge_types[:daily],
          reward_type: Challenge.reward_types[:binary],
          subject: subject,
          start_at: date,
          reward_points: Setting.daily_challenge_points * questions_per_challenge,
          penalty_seconds: 0,
          is_published: true
        )

        # add questions to the challenge
        random_questions = questions.sample(questions_per_challenge)
                                    .sort_by(&:number)
        random_questions.each_with_index do |question, index|
          ChallengeQuestion.create!(
            challenge: challenge,
            question: question,
            display_order: index + 1,
            score: Setting.daily_challenge_points
          )
        end
        progress_bar.increment
      end
    end

    puts "Daily challenges generated for #{subject.name} from #{from_date} to #{to_date}"
  end
end
