require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:payments) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_inclusion_of(:role).in_array(%w[admin user]) }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
  end

  describe 'callbacks' do
    it 'sets the default role to user if not provided' do
      user = build(:user, role: nil)
      user.valid?
      expect(user.role).to eq('user')
    end
  end

  describe '#admin?' do
    context 'when the user is an admin' do
      let(:admin) { create(:user, role: 'admin') }

      it 'returns true' do
        expect(admin.admin?).to be true
      end
    end

    context 'when the user is not an admin' do
      let(:user) { create(:user, role: 'user') }

      it 'returns false' do
        expect(user.admin?).to be false
      end
    end
  end
end
