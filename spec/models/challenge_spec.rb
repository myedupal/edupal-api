require 'rails_helper'

RSpec.describe Challenge, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:subject).optional }
    it { is_expected.to have_many(:challenge_questions).dependent(:destroy) }
    it { is_expected.to have_many(:questions).through(:challenge_questions) }
    it { is_expected.to have_many(:submissions).dependent(:restrict_with_error) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:challenge_questions).allow_destroy(true) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:challenge_type).with_values(daily: 'daily', contest: 'contest', custom: 'custom').backed_by_column_of_type(:string) }
    it { is_expected.to define_enum_for(:reward_type).with_values(binary: 'binary', proportional: 'proportional').backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    describe '.query' do
      let(:keyword) { SecureRandom.uuid }
      let!(:targeted_challenge) { create(:challenge, title: keyword) }
      let!(:untargeted_challenge) { create(:challenge) }

      it 'returns the targeted challenge' do
        expect(described_class.query(keyword)).to include(targeted_challenge)
        expect(described_class.query(keyword)).not_to include(untargeted_challenge)
      end
    end

    describe '.published' do
      let!(:published_challenge) { create(:challenge, is_published: true) }
      let!(:unpublished_challenge) { create(:challenge, is_published: false) }

      it 'returns the published challenge' do
        expect(described_class.published).to include(published_challenge)
        expect(described_class.published).not_to include(unpublished_challenge)
      end
    end

    describe '.with_user_submission_count' do
      let(:user) { create(:user) }
      let!(:submission) { create(:submission, :with_submission_answers, user: user) }

      before do
        create_list(:challenge, 3)
        submission.submit!
      end

      it 'returns the user submission count' do
        challenges = described_class.with_user_submission_count(user.id)
        challenges.each do |challenge|
          if challenge.id == submission.challenge_id
            expect(challenge.user_submission_count).to eq(1)
          else
            expect(challenge.user_submission_count).to eq(0)
          end
        end
      end
    end

    describe '.with_user_success_submission_count' do
      let(:user) { create(:user) }
      let(:challenge) { create(:challenge, :contest, start_at: 1.hour.ago, end_at: 1.hour.from_now) }
      let(:question) { create(:question, :mcq_with_answer) }
      let!(:submission) { create(:submission, user: user, challenge: challenge) }

      before do
        create_list(:challenge, 3)
        create(:challenge_question, challenge: challenge, question: question)
        submission.submission_answers.create!(question: question, answer: question.answers.first.text)
        submission.submit!
      end

      it 'returns the user success submission count' do
        challenges = described_class.with_user_success_submission_count(user.id)
        challenges.each do |challenge|
          if challenge.id == submission.challenge_id
            expect(challenge.user_success_submission_count).to eq(1)
          else
            expect(challenge.user_success_submission_count).to eq(0)
          end
        end
      end
    end

    describe '.ongoing' do
      let!(:ongoing_challenge) { create(:challenge, :custom, subject: nil, end_at: 5.days.from_now) }
      let!(:permanent_challenge) { create(:challenge, :custom, subject: nil, end_at: nil) }
      let!(:ended_challenge) { create(:challenge, :custom, subject: nil, end_at: 5.days.ago) }

      it 'returns the published challenge' do
        expect(described_class.ongoing).to contain_exactly(ongoing_challenge, permanent_challenge)
      end
    end

    describe '.ended' do
      let!(:ongoing_challenge) { create(:challenge, :custom, subject: nil, end_at: 5.days.from_now) }
      let!(:permanent_challenge) { create(:challenge, :custom, subject: nil, end_at: nil) }
      let!(:ended_challenge) { create(:challenge, :custom, subject: nil, end_at: 5.days.ago) }

      it 'returns the published challenge' do
        expect(described_class.ended).to contain_exactly(ended_challenge)
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reward_points) }
    it { is_expected.to validate_presence_of(:start_at) }

    context 'when contest' do
      subject { build(:challenge, challenge_type: :contest) }

      it { is_expected.to validate_presence_of(:end_at) }
    end

    context 'date must be unique' do
      let(:subject) { create(:subject) }
      let(:start_at) { Time.zone.now }
      let(:challenge) { build(:challenge, challenge_type: :daily, subject: subject, start_at: start_at) }

      before do
        travel_to Time.zone.parse('2024-03-12 17:00:00')
        create(:challenge, challenge_type: :daily, subject: subject, start_at: start_at)
      end

      it 'validates uniqueness of start_at' do
        expect(challenge).to be_invalid
      end
    end
  end

  describe 'callbacks' do
    describe '#set_title' do
      let(:subject) { create(:subject) }
      let(:challenge) { build(:challenge, challenge_type: :daily, subject: subject, title: nil, start_at: Time.zone.now) }

      it 'sets title' do
        challenge.save
        expect(challenge.title).to eq("#{subject.curriculum.board} #{subject.curriculum.name} #{subject.name} Daily Challenge #{challenge.start_at.strftime('%d %b %Y')}")
      end
    end

    describe '#set_start_at' do
      let(:start_at) { Time.zone.now }
      let(:challenge) { build(:challenge, challenge_type: :daily, start_at: start_at) }

      it 'sets start_at' do
        challenge.save
        expect(challenge.start_at.to_i).to eq(start_at.beginning_of_day.to_i)
      end
    end

    describe '#set_end_at' do
      let(:start_at) { Time.zone.now }
      let(:challenge) { build(:challenge, challenge_type: :daily, start_at: start_at) }

      it 'sets end_at' do
        challenge.save
        expect(challenge.end_at.to_i).to eq(start_at.end_of_day.to_i)
      end
    end

    describe '#set_custom_start_at' do
      let(:challenge) { build(:challenge, :custom, subject: nil, start_at: nil, end_at: nil) }

      it 'sets start_at' do
        challenge.save
        expect(challenge.start_at).to eq(Time.zone.now.beginning_of_day)
      end
    end
  end
end
