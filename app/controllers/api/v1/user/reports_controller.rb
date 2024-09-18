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

    avg_completion_seconds = submission_answers.distinct(:submission_id).average("submission.completion_seconds")
    submission_count = submission_answers.distinct(:submission_id).count("submission.id")
    avg_score = submission_answers.distinct(:submission_id).average("submission.score")

    render json: {
      daily_streak: current_user.daily_streak,
      max_streak: current_user.maximum_streak,
      total_correct_questions: total_correct_questions,
      total_questions_attempted: total_questions_attempted,
      strength_subject: strength_subject,
      weakness_subject: weakness_subject,
      avg_completion_seconds: avg_completion_seconds,
      submission_count: submission_count,
      avg_score: avg_score
    }, status: :ok
  end

  def daily_challenge_heatmap
    from_date = parse_date(params[:from_date], Date.current.beginning_of_year).beginning_of_day
    to_date = parse_date(params[:from_date], Date.current.end_of_year).end_of_day

    if (to_date - from_date) > (2.year)
      render ErrorResponse("Date range should not exceed 2 year")
      return
    end

    heatmap = Rails.cache.fetch(
      "user/reports/daily_challenge_heatmap/#{current_user.id}-#{current_user.selected_curriculum_id}-#{from_date.to_date.mjd}-#{to_date.to_date.mjd}",
      expires_at: Time.current + 1.hour
    ) do
      submissions = current_user.submissions
                      .joins(challenge: :subject)
                      .where(challenges:
                               {
                                 challenge_type: Challenge.challenge_types[:daily],
                                 subjects: {
                                   curriculum_id: current_user.selected_curriculum_id
                                 }
                               }, status: :submitted)
                      .where(submitted_at: from_date..to_date)
      submissions
        .group("date_trunc('day', submissions.submitted_at)")
        .select("date_trunc('day', submissions.submitted_at) as date")
        .select("COUNT(submissions.id) AS submission_count")
        .order("date DESC").to_a
    end

    render json: {
      heatmap: heatmap,
      active_days: heatmap.count
    }, status: :ok
  end

  def daily_challenge_breakdown
    from_date = parse_date(params[:from_date], Date.current.beginning_of_year).beginning_of_day
    to_date = parse_date(params[:from_date], Date.current.end_of_year).end_of_day

    if (to_date - from_date) > (2.year)
      render ErrorResponse("Date range should not exceed 2 year")
      return
    end

    return render ErrorResponse("Missing breakdown_for") unless params[:breakdown_for].present?

    breakdown_for = params[:breakdown_for].downcase

    subject_stats = Rails.cache.fetch(
      "user/reports/daily_challenge_breakdown/#{current_user.id}-#{current_user.selected_curriculum_id}-#{breakdown_for}-#{from_date.to_date.mjd}-#{to_date.to_date.mjd}",
      expires_at: Time.current + 1.hour
    ) do

      submissions_table = Submission.arel_table
      subjects_table = Subject.arel_table
      challenges_table = Challenge.arel_table
      submission_answers_table = SubmissionAnswer.arel_table

      # create a CTE
      subquery = submissions_table
                   .join(challenges_table).on(submissions_table[:challenge_id].eq(challenges_table[:id]))
                   .join(subjects_table).on(challenges_table[:subject_id].eq(subjects_table[:id]))
                   .where(
                     challenges_table[:challenge_type].eq(Challenge.challenge_types[:daily])
                       .and(subjects_table[:curriculum_id].eq(current_user.selected_curriculum_id))
                       .and(submissions_table[:status].eq('submitted'))
                       .and(submissions_table[:submitted_at].between(from_date..to_date))
                   )
                   .join(submission_answers_table, Arel::Nodes::OuterJoin)
                   .on(submission_answers_table[:submission_id].eq(submissions_table[:id]))

      # add breakdown specific details and grouping
      case breakdown_for
      when 'subject'
        subquery = subquery
                     .project(
                       subjects_table[:id].as('subject_id'),
                       subjects_table[:name].as('subject_name')
                     )
                     .group(subjects_table[:id])
      when 'month'
        subquery = subquery
                     .project(Arel.sql("date_trunc('month', submissions.submitted_at) as month"))
                     .group(Arel.sql("date_trunc('month', submissions.submitted_at)"))
      when 'month_subject'
        subquery = subquery
                     .project(
                       Arel.sql("date_trunc('month', submissions.submitted_at) as month"),
                       subjects_table[:id].as('subject_id'),
                       subjects_table[:name].as('subject_name')
                     )
                     .group(Arel.sql("date_trunc('month', submissions.submitted_at), subjects.id"))
      else
        return render ErrorResponse("Invalid value for parameter breakdown_for")
      end

      # add general details
      subquery = subquery.project(
        submissions_table[:id].count.as('submission_count'),
        submissions_table[:score].sum.as('sum_score'),
        submissions_table[:total_score].sum.as('sum_total_score'),
        Arel.sql('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) as answers_correct_count'),
        submission_answers_table[:id].count.as('answers_count')
      )

      # select from CTE in main query
      main_query = Arel::SelectManager.new
                     .with(Arel::Nodes::As.new(Arel::Table.new('computed_sums'), subquery))
                     .from(Arel::Nodes::SqlLiteral.new('computed_sums'))

      # add breakdown specific details
      case breakdown_for
      when 'subject'
        main_query
          .project(
            Arel.sql('computed_sums.subject_id AS id'),
            Arel.sql('computed_sums.subject_name AS subject_name')
          )
          .order(Arel.sql('answers_correct_ratio DESC'))
      when 'month'
        main_query
          .project(Arel.sql('computed_sums.month AS month'))
          .order(Arel.sql('computed_sums.month DESC'))
      when 'month_subject'
        main_query
          .project(
            Arel.sql('computed_sums.subject_id AS id'),
            Arel.sql('computed_sums.subject_name AS subject_name'),
            Arel.sql('computed_sums.month AS month')
          )
          .order(Arel.sql('computed_sums.month DESC, answers_correct_ratio DESC'))
      end

      # select general details
      main_query.project(
        Arel.sql('computed_sums.submission_count AS submission_count'),
        Arel.sql('computed_sums.sum_score AS sum_score'),
        Arel.sql('computed_sums.sum_total_score AS sum_total_score'),
        Arel.sql('COALESCE(computed_sums.answers_correct_count / NULLIF(answers_count::float, 0), 0) as answers_correct_ratio'),
        Arel.sql('computed_sums.answers_count AS answers_count'),
        Arel.sql('computed_sums.answers_correct_count AS answers_correct_count'),
        Arel.sql('COALESCE(computed_sums.sum_score / NULLIF(computed_sums.sum_total_score::float, 0), 0) AS score_ratio')
      )

      # execute query
      subject_stats = ActiveRecord::Base.connection.execute(main_query.to_sql)

      # group by month if breakdown is by month subject
      subject_stats = subject_stats.group_by { |entry| entry['month'].to_date } if breakdown_for == 'month_subject'

      # convert to array so it can be cached
      subject_stats.to_a
    end

    render json: {
      subject_stats: subject_stats,
      from_date: from_date,
      to_date: to_date
    }
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
    stats = submission_answers.group("subjects.id")
                              .select("subjects.id as id")
                              .select("subjects.name as subject_name")
                              .select('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) as correct_count')
                              .select('COUNT(*) as total_count')
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
      weakness_subject: weakness_subject,
      stats: stats
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
                )  as daily_check_in_points,
                CAST(
                  SUM(
                    CASE
                    WHEN action_type = '#{PointActivity.action_types[:completed_guess_word]}'
                    THEN points
                    ELSE 0
                    END
                  ) AS bigint
                )  as guess_word_points
        FROM point_activities
        WHERE account_id = '#{current_user.id}'
      SQL
    )
    render json: {
      total_points: stats[0]['total_points'],
      mcq_points: stats[0]['mcq_points'],
      daily_challenge_points: stats[0]['daily_challenge_points'],
      daily_check_in_points: stats[0]['daily_check_in_points'],
      guess_word_points: stats[0]['guess_word_points']
    }
  end

  def guess_word
    guess_word_submission = GuessWordSubmission.where(user: current_user)
    status = guess_word_submission.group('status').count

    render json: {
      submission_count: guess_word_submission.count,
      completed_count: guess_word_submission.where.not(completed_at: nil).count,
      status_count: status,
      daily_streak: current_user.guess_word_daily_streak
    }
  end

  def subject
    render ErrorResponse("Missing subject id") unless params[:subject_id].present?
    subject = Subject.find_by(id: params[:subject_id])
    render ErrorResponse("Invalid subject id") unless subject.present?

    submission_answers = current_user.submission_answers
                           .joins({ question: [:subject, :topics] }, :submission)
                           .where(submission: { challenge_id: nil, status: :submitted })
                           .where(question: {
                             question_type: Question.question_types[:mcq],
                             subject_id: subject.id
                           })

    average_time = submission_answers.distinct(:submission_id).average('submission.completion_seconds').to_f
    total_correct_questions = submission_answers.where(is_correct: true).count
    total_questions_attempted = submission_answers.count
    stats = submission_answers.group("topics.id")
              .select("topics.id as id")
              .select("topics.name as topic_name")
              .select('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) as correct_count')
              .select('COUNT(*) as total_count')
              .order(Arel.sql('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) / COUNT(*)::float DESC'))

    strength_subject = if stats.length > 1
                         stats.first.topic_name
                       else
                         'Not enough data'
                       end
    weakness_subject = if stats.length > 1
                         stats.last.topic_name
                       else
                         'Not enough data'
                       end

    render json: {
      subject_name: subject.name,
      average_time: average_time,
      total_correct_questions: total_correct_questions,
      total_questions_attempted: total_questions_attempted,
      strength_subject: strength_subject,
      weakness_subject: weakness_subject,
      stats: stats
    }, status: :ok
  end

  private

    def parse_date(date, fallback = nil)
      return fallback unless date.present?

      Time.zone.parse(date)
    rescue TypeError, Date::Error
      fallback
    end
end
