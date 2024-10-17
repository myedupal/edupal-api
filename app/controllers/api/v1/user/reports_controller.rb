class Api::V1::User::ReportsController < Api::V1::User::ApplicationController
  def daily_challenge
    from_date, to_date = parse_date_range
    submission_answers = current_user.submission_answers
                           .joins({ submission: { challenge: :subject } }, { question: :subject })
                           .where(
                             submission: {
                               challenges: {
                                 challenge_type: Challenge.challenge_types[:daily],
                                 subjects: {
                                   curriculum_id: current_user.selected_curriculum_id
                                 }
                               }
                             })
                           .where.not(evaluated_at: nil)
                           .where(submission: { submitted_at: from_date..to_date })
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

    avg_completion_seconds = submission_answers.distinct(:submission_id).average("submission.completion_seconds").to_f
    submission_count = submission_answers.distinct(:submission_id).count("submission.id").to_f
    avg_score = submission_answers.distinct(:submission_id).average("submission.score").to_f

    render json: {
      daily_streak: current_user.daily_streak,
      max_streak: current_user.maximum_streak,
      total_correct_questions: total_correct_questions,
      total_questions_attempted: total_questions_attempted,
      stats: stats,
      strength_subject: strength_subject,
      weakness_subject: weakness_subject,
      avg_completion_seconds: avg_completion_seconds,
      submission_count: submission_count,
      avg_score: avg_score
    }, status: :ok
  end

  def submission_heatmap
    from_date, to_date = parse_date_range
    subject_id = params[:subject_id]
    challenge_type = params[:challenge_type]
    mcq_type = params[:mcq_type]

    cache_key = [current_user.id, current_user.selected_curriculum_id, from_date.to_date.mjd, to_date.to_date.mjd, subject_id, challenge_type, mcq_type].join('-')
    heatmap = Rails.cache.fetch(
      "user/reports/daily_challenge_heatmap/#{cache_key}",
      expires_at: Time.current + 1.hour
    ) do
      submissions = current_user.submissions
                      .joins(challenge: :subject)
                      .where(
                        challenges: {
                          subjects: { curriculum_id: current_user.selected_curriculum_id }
                        },
                        status: :submitted
                      )
                      .where(submitted_at: from_date..to_date)

      submissions = submissions.where(challenges: { subject_id: subject_id }) if subject_id.present?
      submissions = submissions.where(challenges: { challenge_type: challenge_type }) if challenge_type.present?
      submissions = mcq_type == 'all' ? submissions.where.not(mcq_type: nil) : submissions.where(mcq_type: mcq_type) if mcq_type.present?

      submissions
        .group("date_trunc('day', submissions.submitted_at)")
        .select("date_trunc('day', submissions.submitted_at) as date")
        .select("COUNT(submissions.id) AS submission_count")
        .order("date DESC").to_a
    end

    render json: {
      heatmap: heatmap,
      active_days: heatmap.count,
      total_submissions: heatmap.sum { |h| h[:submission_count] }
    }, status: :ok
  end

  def daily_challenge_breakdown
    from_date, to_date = parse_date_range

    return render json: ErrorResponse.new("Missing breakdown_for") unless params[:breakdown_for].present?

    return render json: ErrorResponse.new("Invalid value for parameter breakdown_for") unless %w[subject month_subject month].include?(params[:breakdown_for].to_s)

    breakdown_for = params[:breakdown_for].downcase

    cache_key = [current_user.id, current_user.selected_curriculum_id, breakdown_for, from_date.to_date.mjd, to_date.to_date.mjd].join('-')

    subject_stats = Rails.cache.fetch(
      "user/reports/daily_challenge_breakdown/#{cache_key}", expires_at: Time.current + 1.hour
    ) do
      query = generate_challenge_stats_query(from_date, to_date, breakdown_for)
      subject_stats = ActiveRecord::Base.connection.execute(query.to_sql)

      # Group results by month if required
      if breakdown_for == 'month_subject'
        subject_stats = subject_stats.group_by { |entry| entry['month'].to_date }
        subject_stats = subject_stats.map do |month, stats|
          {
            "month" => month,
            "stats" => stats
          }
        end
      end

      subject_stats.to_a
    end

    render json: {
      subject_stats: subject_stats,
      from_date: from_date,
      to_date: to_date
    }
  end

  def mcq
    from_date, to_date = parse_date_range
    subject_id = params[:subject_id]

    submission_answers = current_user.submission_answers
                           .joins({ question: :subject }, :submission)
                           .where(submission: { challenge_id: nil, status: :submitted })
                           .where(submission: { submitted_at: from_date..to_date })
                           .where(
                             question: {
                               question_type: Question.question_types[:mcq],
                               subjects: { curriculum_id: current_user.selected_curriculum_id }
                             }
                           )
                           .where.not(evaluated_at: nil)
    submission_answers = submission_answers.where(question: { subject_id: subject_id }) if subject_id.present?

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

    avg_completion_seconds = submission_answers.distinct(:submission_id).average("submission.completion_seconds").to_f
    submission_count = submission_answers.distinct(:submission_id).count("submission.id").to_f
    avg_score = submission_answers.distinct(:submission_id).average("submission.score").to_f

    render json: {
      total_correct_questions: total_correct_questions,
      total_questions_attempted: total_questions_attempted,
      stats: stats,
      strength_subject: strength_subject,
      weakness_subject: weakness_subject,
      avg_completion_seconds: avg_completion_seconds,
      submission_count: submission_count,
      avg_score: avg_score
    }, status: :ok
  end

  def mcq_breakdown
    from_date, to_date = parse_date_range

    subject = nil
    if params[:subject_id].present?
      subject = Subject.find_by(id: params[:subject_id])
      return render json: ErrorResponse.new("Invalid subject id") unless subject.present?
    end

    return render json: ErrorResponse.new("Missing breakdown_for") unless params[:breakdown_for].present?

    return render json: ErrorResponse.new("Invalid value for parameter breakdown_for") unless %w[subject month_subject month].include?(params[:breakdown_for].to_s)

    breakdown_for = params[:breakdown_for].downcase

    cache_key = [current_user.id, current_user.selected_curriculum_id, breakdown_for, subject&.id, from_date.to_date.mjd, to_date.to_date.mjd].join('-')
    mcq_stats = Rails.cache.fetch(
      "user/reports/mcq_breakdown/#{cache_key}", expires_at: Time.current + 1.hour
    ) do
      query = generate_mcq_stats_query(from_date, to_date, subject&.id, breakdown_for)
      mcq_stats = ActiveRecord::Base.connection.execute(query.to_sql)

      if breakdown_for == 'month_subject'
        mcq_stats = mcq_stats.group_by { |entry| entry['month'].to_date }
        mcq_stats = mcq_stats.map do |month, stats|
          {
            "month" => month,
            "stats" => stats
          }
        end
      end

      mcq_stats.to_a
    end

    render json: {
      mcq_stats: mcq_stats,
      from_date: from_date,
      to_date: to_date
    }
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
    from_date, to_date = parse_date_range
    render json: ErrorResponse.new("Missing subject id") unless params[:subject_id].present?
    subject = Subject.find_by(id: params[:subject_id])
    render json: ErrorResponse.new("Invalid subject id") unless subject.present?

    submission_answers = current_user.submission_answers
                           .joins({ question: [:subject, :topics] }, :submission)
                           .where(submission: { challenge_id: nil, status: :submitted })
                           .where(submission: { submitted_at: from_date..to_date })
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

    strength_topic = if stats.length > 1
                       stats.first.topic_name
                     else
                       'Not enough data'
                     end
    weakness_topic = if stats.length > 1
                       stats.last.topic_name
                     else
                       'Not enough data'
                     end

    render json: {
      subject_name: subject.name,
      average_time: average_time,
      total_correct_questions: total_correct_questions,
      total_questions_attempted: total_questions_attempted,
      strength_subject: strength_topic,
      weakness_subject: weakness_topic,
      stats: stats
    }, status: :ok
  end

  def subject_breakdown
    from_date, to_date = parse_date_range

    subject = Subject.find_by(id: params[:subject_id])
    return render json: ErrorResponse.new("Invalid subject id") unless subject.present?

    return render json: ErrorResponse.new("Missing breakdown_for") unless params[:breakdown_for].present?

    return render json: ErrorResponse.new("Invalid value for parameter breakdown_for") unless %w[topic month_topic month].include?(params[:breakdown_for].to_s)

    breakdown_for = params[:breakdown_for].downcase

    cache_key = [current_user.id, current_user.selected_curriculum_id, breakdown_for, subject.id, from_date.to_date.mjd, to_date.to_date.mjd].join('-')
    topic_stats = Rails.cache.fetch(
      "user/reports/subject_breakdown/#{cache_key}", expires_at: Time.current + 1.hour
    ) do
      query = generate_topic_stats_query(from_date, to_date, subject.id, breakdown_for)
      topic_stats = ActiveRecord::Base.connection.execute(query.to_sql)

      if breakdown_for == 'month_topic'
        topic_stats = topic_stats.group_by { |entry| entry['month'].to_date }
        topic_stats = topic_stats.map do |month, stats|
          {
            "month" => month,
            "stats" => stats
          }
        end
      end

      topic_stats.to_a
    end

    render json: {
      topic_stats: topic_stats,
      from_date: from_date,
      to_date: to_date
    }
  end

  private

    def parse_date_range(from_date = params[:from_date], to_date = params[:to_date], max_range = 2.year)
      from_date = parse_date(from_date, Date.current.beginning_of_year).beginning_of_day
      to_date = parse_date(to_date, Date.current.end_of_year).end_of_day

      if (to_date - from_date) > max_range
        render json: ErrorResponse.new("Date range should not exceed maximum allowed range")
        return
      end

      [from_date, to_date]
    end

    def parse_date(date, fallback = nil)
      return fallback unless date.present?

      Time.zone.parse(date)
    rescue TypeError, Date::Error
      fallback
    end

    def generate_challenge_stats_query(from_date, to_date, breakdown_for)
      submissions_table = Submission.arel_table
      subjects_table = Subject.arel_table
      challenges_table = Challenge.arel_table
      submission_answers_table = SubmissionAnswer.arel_table

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
                   .where(
                     submission_answers_table[:evaluated_at].not_eq(nil)
                   )

      # Add breakdown-specific details to the subquery
      subquery = add_breakdown_projection(subquery, breakdown_for, subjects_table)

      # Add general details to the subquery
      subquery.project(
        submissions_table[:id].count.as('submission_count'),
        submissions_table[:score].sum.as('sum_score'),
        submissions_table[:total_score].sum.as('sum_total_score'),
        Arel.sql('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) as answers_correct_count'),
        submission_answers_table[:id].count.as('answers_count')
      )

      # Main query built from the subquery
      main_query = Arel::SelectManager.new
                     .with(Arel::Nodes::As.new(Arel::Table.new('computed_sums'), subquery))
                     .from(Arel::Nodes::SqlLiteral.new('computed_sums'))

      # Add breakdown-specific projections to the main query
      add_main_query_projection(main_query, breakdown_for, subjects_table)
    end

    def generate_mcq_stats_query(from_date, to_date, subject_id, breakdown_for)
      submissions_table = Submission.arel_table
      subjects_table = Subject.arel_table
      submission_answers_table = SubmissionAnswer.arel_table
      questions_table = Question.arel_table

      subquery = submission_answers_table
                   .join(submissions_table).on(submission_answers_table[:submission_id].eq(submissions_table[:id]))
                   .join(questions_table).on(submission_answers_table[:question_id].eq(questions_table[:id]))
                   .join(subjects_table).on(questions_table[:subject_id].eq(subjects_table[:id]))
                   .where(
                     submissions_table[:challenge_id].eq(nil)
                       .and(submissions_table[:status].eq('submitted'))
                       .and(submissions_table[:submitted_at].between(from_date..to_date))
                       .and(questions_table[:question_type].eq(Question.question_types[:mcq]))
                       .and(subjects_table[:curriculum_id].eq(current_user.selected_curriculum_id))
                       .and(submission_answers_table[:evaluated_at]).not_eq(nil)
                   )

      subquery = subquery.where(questions_table[:subject_id].eq(subject_id)) if subject_id.present?

      # Add breakdown-specific details to the subquery
      subquery = add_breakdown_projection(subquery, breakdown_for, subjects_table)

      # Add general details to the subquery
      subquery.project(
        submissions_table[:id].count.as('submission_count'),
        submissions_table[:score].sum.as('sum_score'),
        submissions_table[:total_score].sum.as('sum_total_score'),
        Arel.sql('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) as answers_correct_count'),
        submission_answers_table[:id].count.as('answers_count')
      )

      # Main query built from the subquery
      main_query = Arel::SelectManager.new
                     .with(Arel::Nodes::As.new(Arel::Table.new('computed_sums'), subquery))
                     .from(Arel::Nodes::SqlLiteral.new('computed_sums'))

      # Add breakdown-specific projections to the main query
      add_main_query_projection(main_query, breakdown_for, subjects_table)
    end

    def generate_topic_stats_query(from_date, to_date, subject_id, breakdown_for)
      submissions_table = Submission.arel_table
      subjects_table = Subject.arel_table
      submission_answers_table = SubmissionAnswer.arel_table
      questions_table = Question.arel_table
      question_topics_table = QuestionTopic.arel_table
      topics_table = Topic.arel_table

      subquery = submission_answers_table
                   .join(submissions_table).on(submission_answers_table[:submission_id].eq(submissions_table[:id]))
                   .join(questions_table).on(submission_answers_table[:question_id].eq(questions_table[:id]))
                   .join(subjects_table).on(questions_table[:subject_id].eq(subjects_table[:id]))
                   .join(question_topics_table).on(questions_table[:id].eq(question_topics_table[:question_id]))
                   .join(topics_table).on(question_topics_table[:topic_id].eq(topics_table[:id]))
                   .where(
                     submissions_table[:challenge_id].eq(nil)
                       .and(submissions_table[:status].eq('submitted'))
                       .and(submissions_table[:submitted_at].between(from_date..to_date))
                       .and(questions_table[:question_type].eq(Question.question_types[:mcq]))
                       .and(questions_table[:subject_id].eq(subject_id))
                       .and(submission_answers_table[:evaluated_at]).not_eq(nil)
                   )

      subquery = add_breakdown_projection(subquery, breakdown_for, topics_table)

      subquery.project(
        submissions_table[:id].count.as('submission_count'),
        submissions_table[:score].sum.as('sum_score'),
        Arel.sql('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) as answers_correct_count'),
        submission_answers_table[:id].count.as('answers_count')
      )

      main_query = Arel::SelectManager.new
                     .with(Arel::Nodes::As.new(Arel::Table.new('computed_sums'), subquery))
                     .from(Arel::Nodes::SqlLiteral.new('computed_sums'))

      add_main_query_projection(main_query, breakdown_for, topics_table)
    end

    def add_breakdown_projection(subquery, breakdown_for, grouping_table)
      table_name = grouping_table.name.downcase
      table_name_singular = table_name.singularize
      case breakdown_for
      when 'subject', 'topic', table_name_singular
        subquery.project(
          grouping_table[:id].as("#{table_name_singular}_id"),
          grouping_table[:name].as("#{table_name_singular}_name")
        ).group(grouping_table[:id])
      when 'month'
        subquery.project(
          Arel.sql("date_trunc('month', submissions.submitted_at) as month")
        ).group(Arel.sql("date_trunc('month', submissions.submitted_at)"))
      when 'month_subject', 'month_topic', "month_#{table_name_singular}"
        subquery.project(
          Arel.sql("date_trunc('month', submissions.submitted_at) as month"),
          grouping_table[:id].as("#{table_name_singular}_id"),
          grouping_table[:name].as("#{table_name_singular}_name")
        ).group(Arel.sql("date_trunc('month', submissions.submitted_at), #{table_name}.id"))
      end
    end

    def add_main_query_projection(main_query, breakdown_for, grouping_table)
      table_name = grouping_table.name.downcase.singularize
      case breakdown_for
      when table_name
        main_query.project(
          Arel.sql("computed_sums.#{table_name}_id AS id"),
          Arel.sql("computed_sums.#{table_name}_name AS #{table_name}_name")
        ).order(Arel.sql('answers_correct_ratio DESC, answers_correct_count DESC'))
      when 'month'
        main_query.project(
          Arel.sql('computed_sums.month AS month')
        ).order(Arel.sql('computed_sums.month DESC'))
      when "month_#{table_name}"
        main_query.project(
          Arel.sql("computed_sums.#{table_name}_id AS id"),
          Arel.sql("computed_sums.#{table_name}_name AS #{table_name}_name"),
          Arel.sql('computed_sums.month AS month')
        ).order(Arel.sql('computed_sums.month DESC, answers_correct_ratio DESC, answers_correct_count DESC'))
      end

      main_query.project(
        Arel.sql('computed_sums.submission_count AS submission_count'),
        Arel.sql('computed_sums.sum_score AS sum_score'),
        Arel.sql('computed_sums.answers_count AS answers_count'),
        Arel.sql('computed_sums.answers_correct_count AS answers_correct_count'),
        Arel.sql('COALESCE(computed_sums.answers_correct_count / NULLIF(answers_count::float, 0), 0) as answers_correct_ratio')
      )
    end
end
