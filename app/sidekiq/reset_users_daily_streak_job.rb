class ResetUsersDailyStreakJob
  include Sidekiq::Worker

  def perform
    challenge_submissions_sql = <<-SQL.squish
      SELECT DISTINCT(challenge_submissions.user_id) FROM challenge_submissions
      LEFT JOIN challenges ON challenges.id = challenge_submissions.challenge_id
      WHERE challenge_submissions.submitted_at >= '#{Time.zone.yesterday.beginning_of_day.utc}' AND
            challenge_submissions.submitted_at <= '#{Time.zone.yesterday.end_of_day.utc}' AND
            challenge_submissions.score > 0 AND
            challenge_submissions.score = challenge_submissions.total_score AND
            challenge_submissions.status = 'submitted' AND
            challenges.challenge_type = 'daily'
    SQL
    users = User.where("id NOT IN (#{challenge_submissions_sql})")
    users.update_all(daily_streak: 0)
  end
end
