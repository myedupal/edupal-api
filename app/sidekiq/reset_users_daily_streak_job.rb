class ResetUsersDailyStreakJob
  include Sidekiq::Worker

  def perform
    submissions_sql = <<-SQL.squish
      SELECT DISTINCT(submissions.user_id) FROM submissions
      LEFT JOIN challenges ON challenges.id = submissions.challenge_id
      WHERE submissions.submitted_at >= '#{Time.zone.yesterday.beginning_of_day.utc}' AND
            submissions.submitted_at <= '#{Time.zone.yesterday.end_of_day.utc}' AND
            submissions.score > 0 AND
            submissions.score = submissions.total_score AND
            submissions.status = 'submitted' AND
            challenges.challenge_type = 'daily'
    SQL
    users = User.where("id NOT IN (#{submissions_sql})")
    users.update_all(daily_streak: 0)
  end
end
