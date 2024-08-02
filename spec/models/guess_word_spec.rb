require 'rails_helper'

RSpec.describe GuessWord, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:subject) }
    it { is_expected.to have_many(:guess_word_submissions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:answer) }
    it { is_expected.to validate_presence_of(:attempts) }
    it { is_expected.to validate_presence_of(:reward_points) }
    it { is_expected.to validate_presence_of(:start_at) }

    describe 'end_at' do
      context 'when end at is not set' do
        it { expect(build(:guess_word, end_at: nil)).to be_valid }
      end

      context 'when end at is set' do
        it { expect(build(:guess_word, start_at: Time.zone.now, end_at: Time.zone.now + 1.day)).to be_valid }
        it { expect(build(:guess_word, start_at: Time.zone.now, end_at: Time.zone.now - 1.day)).not_to be_valid }
      end
    end
  end

  describe 'callbacks' do
    describe '#downcase_word' do
      it 'downcase word before saving' do
        guess_word = build(:guess_word, answer: 'TEST')
        expect do
          guess_word.save!
        end.to change(guess_word, :answer).from('TEST').to('test')
      end
    end
  end

  describe 'scopes' do
    describe '.ongoing' do
      let!(:ongoing) { create(:guess_word, start_at: Time.zone.now - 1.day, end_at: Time.zone.now + 1.day) }
      let!(:ongoing_with_no_end) { create(:guess_word, start_at: Time.zone.now - 1.day, end_at: nil) }
      let!(:ended) { create(:guess_word, start_at: Time.zone.now - 7.day, end_at: Time.zone.now - 1.day) }

      it 'returns ongoing guess words' do
        expect(GuessWord.ongoing).to contain_exactly(ongoing, ongoing_with_no_end)
      end
    end
    describe '.ended' do
      let!(:ongoing) { create(:guess_word, start_at: Time.zone.now - 1.day, end_at: Time.zone.now + 1.day) }
      let!(:ongoing_with_no_end) { create(:guess_word, start_at: Time.zone.now - 1.day, end_at: nil) }
      let!(:ended) { create(:guess_word, start_at: Time.zone.now - 7.day, end_at: Time.zone.now - 1.day) }

      it 'returns ended guess words' do
        expect(GuessWord.ended).to contain_exactly(ended)
      end
    end

    describe '.only_submitted_by_user' do
      let!(:guess_word) { create(:guess_word) }
      let!(:other_guess_words) { create_list(:guess_word, 2) }
      let!(:user) { create(:user) }
      let!(:guess_word_submissions) { create(:guess_word_submission, guess_word: guess_word, user: user) }

      before do
        create(:guess_word_submission, guess_word: other_guess_words.first)
      end

      it 'returns guess words with submissions for user' do
        expect(GuessWord.only_submitted_by_user(user)).to contain_exactly(guess_word)
        expect(GuessWord.only_submitted_by_user(user).first!.guess_word_submissions).to contain_exactly(guess_word_submissions)
      end
    end

    describe '.only_unsubmitted_by_user' do
      let!(:guess_word) { create(:guess_word) }
      let!(:other_guess_words) { create_list(:guess_word, 2) }
      let!(:user) { create(:user) }
      let!(:guess_word_submissions) { create(:guess_word_submission, guess_word: guess_word, user: user) }

      before do
        create(:guess_word_submission, guess_word: other_guess_words.first)
      end

      it 'returns guess words with submissions for user' do
        expect(GuessWord.only_unsubmitted_by_user(user)).to_not include(guess_word)
        expect(GuessWord.only_unsubmitted_by_user(user)).to contain_exactly(*other_guess_words)
      end
    end

    describe '.only_completed_by_user' do
      let!(:user) { create(:user) }
      let!(:guess_word) { create(:guess_word) }
      let!(:other_guess_words) { create_list(:guess_word, 2) }
      let!(:completed_guess_word) { create(:guess_word) }

      before do
        create(:guess_word_submission, guess_word: completed_guess_word, user: user, completed_at: Time.now)
        create(:guess_word_submission, guess_word: guess_word, user: user)
        create(:guess_word_submission, guess_word: other_guess_words.first)
      end

      it 'returns guess words with submissions for user' do
        expect(GuessWord.only_completed_by_user(user)).to contain_exactly(completed_guess_word)
      end
    end

    describe '.only_available_for_user' do
      let!(:user) { create(:user) }
      let!(:completed_guess_word) { create(:guess_word) }
      let!(:incomplete_guess_word) { create(:guess_word) }
      let!(:other_guess_words) { create_list(:guess_word, 2) }

      before do
        create(:guess_word_submission, guess_word: completed_guess_word, user: user, completed_at: 1.day.ago)
        create(:guess_word_submission, guess_word: incomplete_guess_word, user: user, completed_at: nil)
        create(:guess_word_submission, guess_word: other_guess_words.first)
      end

      it 'returns guess words with available submissions for user' do
        expect(GuessWord.only_available_for_user(user)).to contain_exactly(incomplete_guess_word, *other_guess_words)
      end
    end

    describe '.only_incomplete_by_user' do
      let!(:user) { create(:user) }
      let!(:guess_word) { create(:guess_word) }
      let!(:other_guess_words) { create_list(:guess_word, 2) }
      let!(:incomplete_guess_word) { create(:guess_word) }

      before do
        create(:guess_word_submission, guess_word: incomplete_guess_word, user: user, completed_at: nil)
        create(:guess_word_submission, guess_word: guess_word, user: user, completed_at: 1.day.ago)
        create(:guess_word_submission, guess_word: other_guess_words.first)
      end

      it 'returns guess words with submissions for user' do
        expect(GuessWord.only_incomplete_by_user(user)).to contain_exactly(incomplete_guess_word)
      end
    end

    describe '.with_reports' do
      let!(:guess_word) { create(:guess_word) }

      context 'with guess word submission' do
        before do
          create(:guess_word_submission, :with_guesses, guess_word: guess_word)
          create_list(:guess_word_submission, 3, :success, :with_guesses, guess_count: 5, guess_word: guess_word)
          create(:guess_word_submission, :expired, :with_guesses, guess_word: guess_word)
          create_list(:guess_word_submission, 2, :failed, :with_guesses, guess_word: guess_word)
        end

        it 'returns guess words with reports' do
          query = GuessWord.with_reports
          expect(query).to contain_exactly(guess_word)
          report = query.first!

          expect(report.guess_word_submissions_count).to eq 7
          expect(report.attributes['completed_count']).to eq 6
          expect(report.attributes['avg_guesses_count']).to be_present
          expect(report.attributes['in_progress_count']).to eq 1
          expect(report.attributes['success_count']).to eq 3
          expect(report.attributes['expired_count']).to eq 1
          expect(report.attributes['failed_count']).to eq 2
        end
      end

      context 'with incomplete submission' do
        before do
          create(:guess_word_submission, :with_guesses, guess_count: 10, guess_word: guess_word)
          create_list(:guess_word_submission, 2, :success, :with_guesses, guess_count: 2, guess_word: guess_word)
        end

        it 'returns average guesses of completed submission' do
          query = GuessWord.with_reports
          expect(query).to contain_exactly(guess_word)
          report = query.first!

          expect(report.guess_word_submissions_count).to eq 3
          expect(report.attributes['completed_count']).to eq 2
          expect(report.attributes['avg_guesses_count']).to eq 2
          expect(report.attributes['in_progress_count']).to eq 1
          expect(report.attributes['success_count']).to eq 2
          expect(report.attributes['expired_count']).to eq 0
          expect(report.attributes['failed_count']).to eq 0
        end
      end
    end
  end
end
