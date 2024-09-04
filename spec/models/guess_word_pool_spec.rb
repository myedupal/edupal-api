require 'rails_helper'

RSpec.describe GuessWordPool, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:subject) }
    it { is_expected.to belong_to(:user).class_name('User').optional }
    it { is_expected.to have_many(:guess_word_questions).counter_cache(:guess_word_questions_count).dependent(:destroy) }
    it { is_expected.to have_many(:guess_word).dependent(:nullify) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:guess_word_questions).allow_destroy(true) }
  end

  describe 'callbacks' do
    describe '#set_title' do
      context 'when title is blank' do
        let(:subject) { create(:subject) }
        let(:pool) { create(:guess_word_pool, subject: subject, title: nil, default_pool: default_pool) }

        context 'when default pool is true' do
          let(:default_pool) { true }

          it 'sets the title to the subject name capitalized' do
            expect(pool.title).to eq("#{subject.name.capitalize} Question Pool")
          end
        end

        context 'when default pool is false' do
          let(:default_pool) { false }

          it 'sets the title to "Untitled Question Pool"' do
            expect(pool.title).to eq('Untitled Question Pool')
          end
        end
      end
    end
  end

  describe 'scopes' do
    describe '.query' do
      let!(:pool) { create(:guess_word_pool, title: 'Test Pool') }
      let!(:another_pool) { create(:guess_word_pool, title: 'Another Pool') }

      it 'returns matching record' do
        expect(described_class.query('Test')).to contain_exactly(pool)
      end
    end

    describe '.by_curriculum' do
      let(:curriculum) { create(:curriculum) }
      let(:subject) { create(:subject, curriculum: curriculum) }
      let!(:pool) { create(:guess_word_pool, subject: subject) }
      let!(:another_pool) { create(:guess_word_pool) }

      it 'returns matching record' do
        expect(described_class.by_curriculum(curriculum)).to contain_exactly(pool)
      end
    end
  end
end
