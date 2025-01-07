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
  end

  describe '#admin?' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }
      
      it 'returns true' do
        expect(user.admin?).to be true
      end
    end

    context 'when user is not admin' do
      let(:user) { create(:user) }
      
      it 'returns false' do
        expect(user.admin?).to be false
      end
    end
  end
end
