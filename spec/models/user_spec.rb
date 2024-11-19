require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:selected_curriculum).class_name('Curriculum').optional }
    it { is_expected.to have_many(:study_goals).dependent(:destroy) }
    it { is_expected.to have_one(:stripe_profile).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:subscriptions).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:active_subscriptions).class_name('Subscription') }
    it { is_expected.to have_many(:submissions).dependent(:destroy) }
    it { is_expected.to have_many(:submission_answers).dependent(:destroy) }
    it { is_expected.to have_many(:activities).dependent(:destroy) }
    it { is_expected.to have_many(:saved_user_exams).dependent(:destroy) }
    it { is_expected.to have_many(:daily_check_ins).dependent(:destroy) }

    it { is_expected.to belong_to(:referred_by).class_name('User').optional.counter_cache(:referred_count) }
    it { is_expected.to have_many(:referred_users).class_name('User').with_foreign_key('referred_by_id').counter_cache(:referred_count) }
    it { is_expected.to have_many(:referral_activities).dependent(:destroy) }
    it { is_expected.to have_many(:referred_activities).class_name('ReferralActivity').dependent(:nullify) }

    describe 'extensions' do
      describe 'active_subscriptions' do
        describe 'for_plan' do
          let(:user) { create(:user) }
          let!(:plan) { create(:plan) }
          let!(:subscription) { create(:subscription, :active, user: user, plan: plan) }
          before { create(:subscription, :active, user: user) }

          it 'filters by plan' do
            expect(user.active_subscriptions.for_plan(plan: plan)).to contain_exactly(subscription)
          end
        end
      end

      describe 'study_goals' do
        describe 'current' do
          let(:user) { create(:user, :with_curriculum) }
          let!(:current_study_goal) { create(:study_goal, user: user, curriculum: user.selected_curriculum) }
          let!(:another_study_goal) { create(:study_goal, user: user) }

          it 'returns current study goal' do
            expect(user.study_goals.current).to eq(current_study_goal)
          end

          context 'when selected_curriculum is nil' do
            before { user.update(selected_curriculum: nil) }

            it 'returns nothing' do
              expect(user.study_goals.current).to be_blank
            end
          end
        end
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'monetize' do
    it { is_expected.to monetize(:referred_credit_cents) }
  end

  describe 'methods' do
    describe '#update_referral' do
      context 'with correct code' do
        let(:user) { create(:user) }
        let!(:referred_by) { create(:user) }

        it 'updates referred by' do
          result = user.update_referral(referred_by.nanoid)
          expect(result).to be_truthy

          expect(user.referred_by).to eq(referred_by)
          expect(user.referred_activities.count).to eq(1)
          expect(referred_by.reload.referral_activities.count).to eq(1)
          referred_activity = user.referred_activities.first!
          expect(referred_activity.user).to eq(referred_by)
          expect(referred_activity.referral_source).to eq(user)
          expect(referred_activity.referral_type).to eq('signup')
        end

        context 'with already referred user' do
          let(:user) { create(:user, referred_by: referred_by) }
          let!(:new_referred_by) { create(:user) }

          it 'returns false' do
            expect(user.update_referral(new_referred_by.nanoid)).to be_falsey
            expect(user.errors[:referral_code]).to include(/have a referral code/)
            expect(user.referred_by).to eq(referred_by)
          end
        end

        context 'with old user' do
          let(:user) { create(:user, created_at: 7.days.ago) }

          it 'returns false' do
            expect(user.update_referral(referred_by.nanoid)).to be_falsey
            expect(user.errors[:referral_code]).to include(/Only new account/)
            expect(user.referred_by).to be_blank
          end
        end

        context 'with empty code' do
          it 'returns false' do
            expect(user.update_referral('')).to be_falsey
            expect(user.errors[:referral_code]).to include(/Missing referral code/)
            expect(user.referred_by).to be_blank
          end
        end

        context 'with invalid code' do
          it 'returns false for invalid code' do
            expect(user.update_referral('123')).to be_falsey
            expect(user.errors[:referral_code]).to include(/Invalid referral code/)
            expect(user.referred_by).to be_blank
          end

          it 'returns false for self' do
            expect(user.update_referral(user.nanoid)).to be_falsey
            expect(user.errors[:referral_code]).to include(/Invalid referral code/)
            expect(user.referred_by).to be_blank
          end
        end

      end
    end

  end

  describe '.scopes' do
    describe '.query' do
      let!(:user) { create(:user, name: 'John Doe', email: 'john.doe@example.com', nanoid: '123456') }

      it 'returns user with name' do
        expect(User.query('john')).to include(user)
      end

      it 'returns user with email' do
        expect(User.query('john.doe')).to include(user)
      end

      it 'returns user with nanoid' do
        expect(User.query('123456')).to include(user)
      end

      it 'does not returns user with other query' do
        expect(User.query('7890')).not_to include(user)
      end
    end
  end
end
