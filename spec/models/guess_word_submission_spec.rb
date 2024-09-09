require 'rails_helper'

RSpec.describe GuessWordSubmission, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:guess_word).counter_cache }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:guesses).dependent(:destroy).class_name('GuessWordSubmissionGuess').counter_cache(:guesses_count) }
    it { is_expected.to have_many(:point_activities).dependent(:destroy) }
  end

  describe 'validations' do
    subject { create(:guess_word_submission) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:guess_word_id).case_insensitive }
  end

  describe 'aasm' do
    let(:testing_words) { [] }
    before do
      testing_words.each { |word| GuessWordDictionary.create(word: word) }
    end

    describe 'default state' do
      it { is_expected.to have_state(:in_progress) }
    end

    describe 'guards' do
      describe '#game_started?' do
        let(:testing_words) { %w[word test] }
        let(:guess_word) { create(:guess_word, start_at: start_at, end_at: 14.days.from_now, answer: 'word') }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }

        context 'when game started' do
          let(:start_at) { 1.day.ago }
          it 'allow game to progress' do
            expect(guess_word_submission).to transition_from(:in_progress).to(:in_progress).on_event(:guess, 'test')
          end
        end

        context 'when game has not started' do
          let(:start_at) { 1.day.from_now }
          it 'does not allow guessing' do
            expect(guess_word_submission).not_to allow_event(:guess, 'test')
            expect(guess_word_submission.errors[:guess_word]).to match([/has not started/])
          end
        end
      end

      describe '#guess_is_same_length?' do
        let(:testing_words) { %w[flash word editor shape] }
        let(:guess_word) { create(:guess_word, start_at: 1.day.ago, end_at: 14.days.from_now, answer: 'flash', attempts: 3) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }

        it 'allows same length guesses' do
          expect(guess_word_submission).to allow_event(:guess).with('shape')
        end

        it 'does not allow shorter guesses' do
          expect(guess_word_submission).not_to allow_event(:guess).with('word')
          expect(guess_word_submission.errors[:guess]).to match([/same length as the answer/])
        end

        it 'does not allow longer guesses' do
          expect(guess_word_submission).not_to allow_event(:guess).with('editor')
          expect(guess_word_submission.errors[:guess]).to match([/same length as the answer/])
        end
      end

      describe '#guess_is_word?' do
        let(:guess_word) { create(:guess_word, start_at: 1.day.ago, end_at: 14.days.from_now, answer: Faker::Lorem.characters(number: 10), attempts: 3) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }
        let(:test_word) { Faker::Lorem.characters(number: 10) }
        let(:testing_words) { [test_word] }

        it 'allows word in dictionary' do
          expect(guess_word_submission).to allow_event(:guess).with(test_word)
        end

        context 'word not in dictionary' do
          it 'does not allow non words' do
            expect(guess_word_submission).not_to allow_event(:guess).with(Faker::Lorem.characters(number: 10))
            expect(guess_word_submission.errors[:guess]).to match([/not in the dictionary/])
          end
        end

        context 'with pool' do
          let(:guess_word) do
            create(:guess_word, start_at: 1.day.ago, end_at: 14.days.from_now,
                   answer: Faker::Lorem.characters(number: 10), attempts: 3,
                   guess_word_pool: guess_word_pool)
          end
          let(:guess_word_pool) { create(:guess_word_pool) }
          let(:another_test_word) { Faker::Lorem.characters(number: 10) }

          before { create(:guess_word_question, guess_word_pool: guess_word_pool, word: another_test_word) }

          it 'allows word in dictionary' do
            expect(guess_word_submission).to allow_event(:guess).with(test_word)
          end

          it 'allows word in pool' do
            expect(guess_word_submission).to allow_event(:guess).with(another_test_word)
          end

          it 'does not allow non words' do
            expect(guess_word_submission).not_to allow_event(:guess).with(Faker::Lorem.characters(number: 10))
            expect(guess_word_submission.errors[:guess]).to match([/not in the dictionary/])
          end
        end
      end

      describe '#game_ended?' do
        let(:testing_words) { %w[word test] }
        let(:guess_word) { create(:guess_word, start_at: 7.days.ago, end_at: end_at, answer: 'word', attempts: 5) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }

        context 'when game ended' do
          let(:end_at) { 1.day.ago }
          it 'transition to expired' do
            expect(guess_word_submission).to transition_from(:in_progress).to(:expired).on_event(:guess, 'test')
          end
        end

        context 'when game ongoing' do
          let(:end_at) { 1.day.from_now }
          it 'transition to expired' do
            expect(guess_word_submission).to transition_from(:in_progress).to(:in_progress).on_event(:guess, 'test')
          end
        end
      end

      describe '#within_attempts?' do
        let(:testing_words) { %w[word test] }
        let(:guess_word) { create(:guess_word, start_at: 7.days.ago, end_at: 7.days.from_now, answer: 'word', attempts: 2) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }
        let(:previous_attempts) { 0 }
        before { create_list(:guess_word_submission_guess, previous_attempts, guess_word_submission: guess_word_submission) }

        context 'with no guesses' do
          it 'game continues' do
            expect(guess_word_submission).to transition_from(:in_progress).to(:in_progress).on_event(:guess, 'test')
          end
        end

        context 'with one previous guess' do
          let(:previous_attempts) { 1 }

          it 'game fails' do
            expect(guess_word_submission).to transition_from(:in_progress).to(:failed).on_event(:guess, 'test')
          end
        end

        context 'with two previous guess' do
          let(:previous_attempts) { 2 }

          it 'game fails' do
            expect(guess_word_submission).to transition_from(:in_progress).to(:failed).on_event(:guess, 'test')
          end
        end
      end
    end

    describe 'events' do
      let(:testing_words) { %w[word test] }
      let(:end_at) { 3.days.from_now }
      let(:guess_word) { create(:guess_word, start_at: 2.days.ago, end_at: end_at, answer: 'word', attempts: 3) }
      let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }

      describe 'guess' do
        context 'expired' do
          let(:end_at) { 1.day.ago }

          it { expect(guess_word_submission).to transition_from(:in_progress).to(:expired).on_event(:guess, 'test') }
        end

        context 'in_progress' do
          it { expect(guess_word_submission).to transition_from(:in_progress).to(:in_progress).on_event(:guess, 'test') }
        end

        context 'failed' do
          before { create_list(:guess_word_submission_guess, 2, guess_word_submission: guess_word_submission) }

          it { expect(guess_word_submission).to transition_from(:in_progress).to(:failed).on_event(:guess, 'test') }
        end
      end

      describe 'success' do
        it { expect(guess_word_submission).to transition_from(:in_progress).to(:success).on_event(:success) }
      end

      describe 'fail' do
        it { expect(guess_word_submission).to transition_from(:in_progress).to(:failed).on_event(:fail) }
      end
    end

    describe 'afters' do
      let(:answer) { Faker::Lorem.characters(number: 10) }
      let(:test_word) { Faker::Lorem.characters(number: 10) }
      let(:testing_words) { [answer, test_word] }

      describe '#add_guess' do
        let(:guess_word) { create(:guess_word, answer: answer, attempts: 3) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }

        it 'adds to guesses' do
          expect { guess_word_submission.guess!(test_word) }.to change(GuessWordSubmissionGuess, :count).by(1)
        end

        context 'with uppercase' do
          let(:test_word) { 'TESTING123' }

          it 'downcase words' do
            expect(guess_word_submission).to transition_from(:in_progress).to(:in_progress).on_event(:guess, test_word)
            expect(guess_word_submission.guesses.count).to eq(1)
            expect(guess_word_submission.guesses.first!.guess).to eq('testing123')
          end
        end
      end

      describe '#update_game_status' do
        let(:end_at) { 1.day.from_now }
        let(:guess_word) { create(:guess_word, answer: answer, attempts: 3, end_at: end_at) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }

        context 'with first guess' do
          context 'with incorrect guess' do
            it 'mark game as in progress' do
              expect(guess_word_submission).to transition_from(:in_progress).to(:in_progress).on_event(:guess, test_word)
            end
          end

          context 'with correct guess' do
            it 'mark game as success' do
              expect(guess_word_submission).to transition_from(:in_progress).to(:success).on_event(:guess, answer)
            end
          end
        end

        context 'with expired game' do
          let(:end_at) { 1.day.ago }

          context 'with incorrect guess' do
            it 'mark game as expired' do
              expect(guess_word_submission).to transition_from(:in_progress).to(:expired).on_event(:guess, test_word)
            end
          end

          context 'with correct guess' do
            it 'mark game as expired' do
              expect(guess_word_submission).to transition_from(:in_progress).to(:expired).on_event(:guess, answer)
            end
          end
        end

        context 'with last guess' do
          before do
            create_list(:guess_word_submission_guess, 2, guess_word_submission: guess_word_submission)
          end

          context 'with incorrect guess' do
            it 'mark game as failed' do
              expect(guess_word_submission).to transition_from(:in_progress).to(:failed).on_event(:guess, test_word)
            end
          end

          it 'does not allow retrying' do
            expect(guess_word_submission).to transition_from(:in_progress).to(:failed).on_event(:guess, test_word)
            expect(guess_word_submission).to_not allow_event(:guess, answer)
          end

          context 'with correct guess' do
            it 'mark game as success' do
              expect(guess_word_submission).to transition_from(:in_progress).to(:success).on_event(:guess, answer)
            end
          end
        end
      end

      describe '#create_guess_word_point_activity' do
        let(:guess_word) { create(:guess_word, answer: answer, attempts: 1) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }

        context 'with correct guess' do
          it 'creates point activity' do
            expect { guess_word_submission.guess!(answer) }.to change(PointActivity, :count).by(1)
            expect(guess_word_submission.status).to eq('success')
          end
        end

        context 'with incorrect guess' do
          it 'does not creates point activity' do
            expect { guess_word_submission.guess!(test_word) }.not_to change(PointActivity, :count)
            expect(guess_word_submission.status).to eq('failed')
          end
        end
      end

      describe '#set_completed_at' do
        let(:invalid_word) { Faker::Lorem.characters(number: 10) }
        let(:guess_word) { create(:guess_word, answer: answer, attempts: 1) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word, completed_at: nil) }

        context 'with correct guess' do
          it 'sets completed at' do
            expect(guess_word_submission.guess!(answer)).to be_truthy
            expect(guess_word_submission.completed_at).to be_present
            expect(guess_word_submission.status).to eq('success')
          end
        end

        context 'with wrong guess' do
          it 'sets completed at' do
            expect(guess_word_submission.guess!(test_word)).to be_truthy
            expect(guess_word_submission.completed_at).to be_present
            expect(guess_word_submission.status).to eq('failed')
          end
        end

        context 'with invalid guess' do
          it 'does not set completed at' do
            expect(guess_word_submission.guess!(invalid_word)).to be_falsey
            expect(guess_word_submission.completed_at).to be_nil
            expect(guess_word_submission.status).to eq('in_progress')
          end
        end

        context 'with expired game' do
          let(:guess_word) { create(:guess_word, answer: answer, attempts: 1, start_at: 2.days.ago, end_at: 1.day.ago) }
          it 'sets completed at' do
            expect(guess_word_submission.guess!(test_word)).to be_truthy
            expect(guess_word_submission.completed_at).to be_present
            expect(guess_word_submission.status).to eq('expired')
          end
        end
      end

      describe '#update_user_streak' do
        let(:guess_word) { create(:guess_word, answer: answer, attempts: 3) }
        let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }

        context 'with first submission  of the day' do
          context 'with first attempt' do
            context 'with correct guess' do
              it 'increments user streak' do
                expect { guess_word_submission.guess!(answer) }.to change { guess_word_submission.user.guess_word_daily_streak }.by(1)
              end
            end

            context 'with incorrect guess' do
              it 'increments user streak' do
                expect { guess_word_submission.guess!(test_word) }.not_to(change { guess_word_submission.user.guess_word_daily_streak })
              end
            end
          end

          context 'with final attempt' do
            before do
              create_list(:guess_word_submission_guess, 2, guess_word_submission: guess_word_submission)
            end

            context 'with correct guess' do
              it 'increments user streak' do
                expect { guess_word_submission.guess!(answer) }.to change { guess_word_submission.user.guess_word_daily_streak }.by(1)
              end
            end

            context 'with incorrect guess' do
              it 'increments user streak' do
                expect { guess_word_submission.guess!(answer) }.to change { guess_word_submission.user.guess_word_daily_streak }.by(1)
              end
            end
          end
        end

        context 'with second submission of the day' do
          before do
            create(:guess_word_submission, user: guess_word_submission.user, completed_at: Time.zone.today.beginning_of_day)
          end

          context 'with correct guess' do
            it 'does not increment user streak' do
              expect { guess_word_submission.guess!(test_word) }.not_to(change { guess_word_submission.user.guess_word_daily_streak })
            end
          end
        end
      end
    end
  end
end
