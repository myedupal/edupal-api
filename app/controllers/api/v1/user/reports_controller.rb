class Api::V1::User::ReportsController < Api::V1::User::ApplicationController
  def daily_challenge
    submission_answers = current_user.submission_answers
                                     .joins({ submission: { challenge: :subject } }, { question: :subject })
                                     .where(submission: {
                                              challenges: {
                                                challenge_type: Challenge.challenge_types[:daily],
                                                subjects: {
                                                  curriculum_id: current_user.selected_curriculum_id
                                                }
                                              }
                                            })
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
                                     .joins({ question: :subject }, :submission)
                                     .where(submission: { challenge_id: nil, status: :submitted })
                                     .where(question: {
                                              question_type: Question.question_types[:mcq],
                                              subjects: { curriculum_id: current_user.selected_curriculum_id }
                                            })

    average_time = submission_answers.distinct(:submission_id).average('submission.completion_seconds').to_f
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

  def points
    # query to get total points, mcq points, daily challenge points, daily check in points with raw sql
    stats = ActiveRecord::Base.connection.execute(
      <<~SQL.squish
        SELECT CAST(SUM(points) AS bigint) as total_points,
                CAST(
                  SUM(
                    CASE
                    WHEN action_type = '#{PointActivity.action_types[:answered_question]}'
                    THEN points
                    ELSE 0
                    END
                  ) AS bigint
                ) as mcq_points,
                CAST(
                  SUM(
                    CASE
                    WHEN action_type = '#{PointActivity.action_types[:daily_challenge]}'
                    THEN points
                    ELSE 0
                    END
                  ) AS bigint
                ) as daily_challenge_points,
                CAST(
                  SUM(
                    CASE
                    WHEN action_type = '#{PointActivity.action_types[:daily_check_in]}'
                    THEN points
                    ELSE 0
                    END
                  ) AS bigint
                )  as daily_check_in_points
        FROM point_activities
        WHERE account_id = '#{current_user.id}'
      SQL
    )
    render json: {
      total_points: stats[0]['total_points'],
      mcq_points: stats[0]['mcq_points'],
      daily_challenge_points: stats[0]['daily_challenge_points'],
      daily_check_in_points: stats[0]['daily_check_in_points']
    }
  end
end
