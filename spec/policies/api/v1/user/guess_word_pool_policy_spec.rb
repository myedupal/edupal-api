require 'rails_helper'

RSpec.describe Api::V1::User::GuessWordPoolPolicy, type: :policy do
  let(:user) { create(:user) }

  subject { described_class }

  describe ".scope" do
    let(:scope) { GuessWordPool.all }
    let(:organization) { create(:organization) }

    context "when published" do
      let!(:guess_word_pool) { create(:guess_word_pool, published: true) }
      let!(:another_guess_word_pool) { create(:guess_word_pool, user_id: create(:user), published: false) }
      let!(:organization_guess_word_pool) { create(:guess_word_pool, organization: organization, published: true) }
      let!(:another_organization_guess_word_pool) { create(:guess_word_pool, organization: create(:organization), published: true) }

      context "when user is not in the organization" do
        it "returns guess word pool without organization" do
          expect(subject::Scope.new(user, scope).resolve).to contain_exactly(guess_word_pool)
        end
      end

      context "when user is in the organization" do
        before do
          create(:organization_account, organization: organization, account: user)
          user.update(selected_organization: organization)
        end

        it "returns guess word pool with organization" do
          expect(subject::Scope.new(user, scope).resolve).to contain_exactly(organization_guess_word_pool)
        end
      end
    end

    context "when unpublished" do
      let(:owning_user) { user }
      let!(:guess_word_pool) { create(:guess_word_pool, user_id: user.id, published: false) }
      let!(:published_guess_word_pool) { create(:guess_word_pool, published: true) }
      let!(:another_guess_word_pool) { create(:guess_word_pool, user_id: create(:user), published: false) }
      let!(:organization_user_guess_word_pool) { create(:guess_word_pool, user_id: user.id, organization: organization, published: false) }
      let!(:organization_published_guess_word_pool) { create(:guess_word_pool, organization: organization, published: true) }
      let!(:organization_another_guess_word_pool) { create(:guess_word_pool, organization: organization, published: false) }

      context "when user is the owner" do
        it "returns guess word pool" do
          expect(subject::Scope.new(user, scope).resolve).to contain_exactly(guess_word_pool, published_guess_word_pool)
        end
      end

      context "when user is in the organization" do
        before do
          create(:organization_account, organization: organization, account: user)
          user.update(selected_organization: organization)
        end

        it "returns organization guess word pool" do
          expect(subject::Scope.new(user, scope).resolve).to contain_exactly(organization_user_guess_word_pool, organization_published_guess_word_pool)
        end
      end
    end
  end
end
