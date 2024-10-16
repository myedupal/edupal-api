class Api::V1::Admin::ReportsController < Api::V1::Admin::ApplicationController
  def user_current_streaks_count
    specific_count = 7
    specific_count = params[:specific_count].to_i if params[:specific_count].present?

    sum_ranges = parse_sum_ranges(7, 6, -1)
    sum_ranges.append(["over", sum_ranges.last])

    @users = User.where(daily_streak: 1..)
    @specific = @users.where(daily_streak: 1..specific_count).order(:daily_streak).group(:daily_streak).count

    query = generate_ranges_sql(sum_ranges) do |range|
      if range.is_a?(Array) && range[0] == 'over'
        User.arel_table[:daily_streak].gteq(range[1]).to_sql
      else
        User.arel_table[:daily_streak].lteq(range).to_sql
      end
    end

    @sum = @users.select(query).take.attributes.except('id')

    @since_month_start = @users.where(daily_streak: ..Date.today.day).count

    render json: {
      specific: @specific,
      sum: @sum,
      since_month_start: @since_month_start
    }, status: :ok
  end

  def user_max_streaks_count
    specific_count = 10
    specific_count = params[:specific_count].to_i if params[:specific_count].present?
    sum_ranges = parse_sum_ranges(10, 5, -1)
    sum_ranges.append(["over", sum_ranges.last])

    @users = User.where(maximum_streak: 1..)
    @specific = @users.where(maximum_streak: 1..specific_count).order(:maximum_streak).group(:maximum_streak).count

    query = generate_ranges_sql(sum_ranges) do |range|
      if range.is_a?(Array) && range[0] == 'over'
        User.arel_table[:maximum_streak].gteq(range[1]).to_sql
      else
        User.arel_table[:maximum_streak].lteq(range).to_sql
      end
    end

    @sum = @users.select(query).take.attributes.except('id')

    render json: {
      specific: @specific,
      sum: @sum
    }, status: :ok
  end

  def user_recent_check_in_count
    sum_ranges = parse_sum_ranges(7, 3, 3)
    months = 3
    months = params[:months].to_i if params[:months].present?

    daily_check_ins = DailyCheckIn.arel_table

    sum_query = generate_ranges_arel(sum_ranges) do |i|
      start_date = i.days.ago.beginning_of_day
      daily_check_ins
        .project(daily_check_ins[:user_id].count(true).as("\"#{i}\""))
        .where(daily_check_ins[:date].between(start_date..Date.today.end_of_day))
    end
    @sum = ActiveRecord::Base.connection.select_one(sum_query)

    month_query = generate_ranges_arel(0..months) do |i|
      start_date = i.months.ago.beginning_of_month
      end_date = i.months.ago.end_of_month
      daily_check_ins
        .project(daily_check_ins[:user_id].count(true).as("\"#{i}\""))
        .where(daily_check_ins[:date].between(start_date..end_date))
    end
    @monthly = ActiveRecord::Base.connection.select_one(month_query)

    render json: {
      sum: @sum,
      monthly: @monthly
    }, status: :ok
  end

  def user_recent_submission_count
    sum_ranges = parse_sum_ranges(7, 3, 1)
    months = 3
    months = params[:months].to_i if params[:months].present?

    submissions = Submission.arel_table
    sum_query = generate_ranges_arel(sum_ranges) do |i|
      start_date = i.days.ago.beginning_of_day
      submissions
        .project(submissions[:user_id].count(true).as("\"#{i}\""))
        .where(submissions[:submitted_at].between(start_date..Date.today.end_of_day))
    end
    @sum = ActiveRecord::Base.connection.select_one(sum_query)

    month_query = generate_ranges_arel(0..months) do |i|
      start_date = i.months.ago.beginning_of_month
      end_date = i.months.ago.end_of_month
      submissions
        .project(submissions[:user_id].count(true).as("\"#{i}\""))
        .where(submissions[:submitted_at].between(start_date..end_date))
    end
    @monthly = ActiveRecord::Base.connection.select_one(month_query)

    render json: {
      sum: @sum,
      monthly: @monthly
    }, status: :ok
  end

  def submission_recent_count
    sum_ranges = parse_sum_ranges(7, 3, 1)
    months = 3
    months = params[:months].to_i if params[:months].present?

    submissions = Submission.arel_table
    sum_query = generate_ranges_arel(sum_ranges) do |i|
      start_date = i.days.ago.beginning_of_day
      submissions
        .project(submissions[:id].count.as("\"#{i}\""))
        .where(submissions[:submitted_at].between(start_date..Date.today.end_of_day))
    end
    @sum = ActiveRecord::Base.connection.select_one(sum_query)

    month_query = generate_ranges_arel(0..months) do |i|
      start_date = i.months.ago.beginning_of_month
      end_date = i.months.ago.end_of_month
      submissions
        .project(submissions[:id].count.as("\"#{i}\""))
        .where(submissions[:submitted_at].between(start_date..end_date))
    end
    @monthly = ActiveRecord::Base.connection.select_one(month_query)

    render json: {
      sum: @sum,
      monthly: @monthly
    }, status: :ok
  end

  def point_activity_recent_count
    sum_ranges = parse_sum_ranges(7, 3, -1)
    months = 3
    months = params[:months].to_i if params[:months].present?

    @point_activities = PointActivity
    @sum = {}
    sum_ranges.each_with_index do |range, _|
      @sum[range] = @point_activities.where(created_at: range.days.ago.beginning_of_day..Date.today.end_of_day).group('action_type').count
    end

    @monthly = {}
    (0..months).each_with_index do |range, _|
      range_date = range.months.ago.beginning_of_month..range.months.ago.end_of_month
      @monthly[range] = @point_activities.where(created_at: range_date).group('action_type').count
    end

    render json: {
      sum: @sum,
      monthly: @monthly
    }, status: :ok
  end

  def export_user_csv
    @users = User.preload(:selected_curriculum)
    @users = keyword_queryable(@users)
    @users = @users.where(id: params[:user_ids]) if params[:user_ids].present?

    csv_map = {
      id: 'id',
      email: 'email',
      name: 'name',
      phone_number: 'phone_number',
      created_at: 'created_at',
      updated_at: 'updated_at',
      points: 'points',
      daily_streak: 'daily_streak',
      maximum_streak: 'maximum_streak',
      selected_curriculum: 'selected_curriculum.name',
      total_submission: 'submissions.count',
      total_question_attempted: 'submission_answers.count',
      referred_count: 'referred_count',
      strength_subject: nil,
      weakness_subject: nil,
      last_checkin_date: nil,
      daily_checkin_count: nil
    }

    injected = lambda do |user|
      stats = user.submission_answers
                .joins({ submission: { challenge: :subject } }, { question: :subject })
                .where(
                  submission: {
                    challenges: {
                      challenge_type: Challenge.challenge_types[:daily],
                      subjects: {
                        curriculum_id: user.selected_curriculum_id
                      }
                    }
                  }
                )
                .where.not(evaluated_at: nil)
                .group("subjects.id")
                .select("subjects.id as id")
                .select("subjects.name as subject_name")
                .select('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) as correct_count')
                .select('COUNT(*) as total_count')
                .order(Arel.sql('SUM(CASE WHEN submission_answers.is_correct THEN 1 ELSE 0 END) / COUNT(*)::float DESC'))

      strength_subject = (stats.length > 1) ? stats.first.subject_name : 'Not enough data'
      weakness_subject = (stats.length > 1) ? stats.last.subject_name : 'Not enough data'

      last_checkin_date = user.daily_check_ins.order(date: :desc).first&.date
      [strength_subject, weakness_subject, last_checkin_date, user.daily_check_ins.count]
    end

    csv_headers = csv_map.keys
    csv_attributes = csv_map.compact.values

    stream_csv enumerate_csv(@users, csv_headers, csv_attributes, &injected), filename: "user_export_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
  end

  private

    # Parses a sum range from the params
    # If params sum_ranges is present, it will parse the sum_ranges in comma separated format
    # otherwise it will create an array with multiple of interval for given times and prepend 0..prepend
    #
    # @param interval [Integer] the base interval
    # @param times [Integer] the times to multiply the interval by
    # @param prepend [Integer] the number of digit to prepend from 0..prepend
    # @return [Array] an array of numbers
    def parse_sum_ranges(interval = 7, times = 6, prepend = -1)
      if params[:sum_ranges].present?
        ranges = params[:sum_ranges].split(',').map(&:to_i)
        return ranges if ranges.count > 1 && ranges.first.zero?
      end

      sum_weeks = times
      sum_weeks = params[:sum_times].to_i if params[:sum_times].present?
      sum_interval = interval
      sum_interval = params[:sum_interval].to_i if params[:sum_interval].present?
      prepend = params[:sum_prepend].to_i if params[:sum_prepend].present?

      (1..sum_weeks).map { |i| sum_interval * i }.prepend(*(0..prepend))
    end

    def generate_ranges_sql(sum_ranges, &block)
      sum_ranges.map do |range|
        "COUNT(*) FILTER (WHERE #{block.call(range)}) AS \"#{range.is_a?(Array) ? range[0] : range}\""
      end.join(",\n")
    end

    def generate_ranges_arel(sum_ranges, &block)
      names = []
      queries = sum_ranges.map do |range|
        query = block.call(range)
        name = Arel::Table.new(range.is_a?(Array) ? range[0] : range)
        names.push(name)
        Arel::Nodes::As.new(name, query)
      end

      Arel::SelectManager.new.with(queries).from(names).project(Arel.star)
    end

end
