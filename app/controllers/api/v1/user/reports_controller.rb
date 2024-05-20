class Api::V1::User::ReportsController < Api::V1::User::ApplicationController
  def daily_challenge
    submission_answers = current_user.submission_answers
                                     .joins({ challenge_submission: :challenge }, { question: :subject })
                                     .where(challenge_submission: { challenges: { challenge_type: Challenge.challenge_types[:daily] } })
                                     .where.not(evaluated_at: nil)
    total_correct_questions = submission_answers.where(is_correct: true).count
    total_questions_attempted = submission_answers.count

    stats = submission_answers.group("subjects.name")
                              .select("subjects.name as subject_name")
                              .order(Arel.sql('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) / COUNT(*)::float DESC'))

    strength_subject = if stats.length > 1
                         stats.first.subject_name
                       else
                         'Not enough data'
                       end
    weakness_subject = if stats.length > 1
                         stats.last.subject_name
                       else
                         'Not enough data'
                       end

    render json: {
      daily_streak: current_user.daily_streak,
      total_correct_questions: total_correct_questions,
      total_questions_attempted: total_questions_attempted,
      strength_subject: strength_subject,
      weakness_subject: weakness_subject
    }, status: :ok
  end

  def mcq
    submission_answers = current_user.submission_answers
                                     .joins({ question: :subject })
                                     .where(challenge_submission_id: nil)
                                     .where.not(evaluated_at: nil)
                                     .where(question: { question_type: Question.question_types[:mcq] })

    average_time = submission_answers.average(:recorded_time)
    total_correct_questions = submission_answers.where(is_correct: true).count
    total_questions_attempted = submission_answers.count
    stats = submission_answers.group("subjects.name")
                              .select("subjects.name as subject_name")
                              .order(Arel.sql('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) / COUNT(*)::float DESC'))

    strength_subject = if stats.length > 1
                         stats.first.subject_name
                       else
                         'Not enough data'
                       end
    weakness_subject = if stats.length > 1
                         stats.last.subject_name
                       else
                         'Not enough data'
                       end
    render json: {
      average_time: average_time,
      total_correct_questions: total_correct_questions,
      total_questions_attempted: total_questions_attempted,
      strength_subject: strength_subject,
      weakness_subject: weakness_subject
    }, status: :ok
  end
end
