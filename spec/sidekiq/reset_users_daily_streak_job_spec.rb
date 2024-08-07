require 'rails_helper'

RSpec.describe ResetUsersDailyStreakJob, type: :job do
  describe '#perform' do
    let!(:user) { create(:user, daily_streak: 3, maximum_streak: 10, guess_word_daily_streak: 3) }
    let!(:user2) { create(:user, daily_streak: 3, maximum_streak: 7, guess_word_daily_streak: 2) }
    let!(:user3) { create(:user, daily_streak: 2, maximum_streak: 2, guess_word_daily_streak: 1) }

    before do
      travel_to Time.zone.parse('2024-05-10 17:00:00') do
        create(:submission, :with_submission_answers, :submitted, user: user)
        create(:guess_word_submission, user: user, completed_at: Time.zone.now)
      end
    end

    it 'resets daily streak for users who did not submit a daily challenge' do
      travel_to Time.zone.parse('2024-05-11 00:00:00') do
        described_class.new.perform
      end
      user.reload
      user2.reload
      user3.reload

      expect(user.daily_streak).to eq(4)
      expect(user.maximum_streak).to eq(10)
      expect(user.guess_word_daily_streak).to eq(3)
      expect(user2.daily_streak).to eq(0)
      expect(user2.maximum_streak).to eq(7)
      expect(user2.guess_word_daily_streak).to eq(0)
      expect(user3.daily_streak).to eq(0)
      expect(user3.maximum_streak).to eq(2)
      expect(user3.guess_word_daily_streak).to eq(0)
    end
  end
end
