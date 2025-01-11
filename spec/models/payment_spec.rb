require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:cpf) }
    it { should allow_value('12345678901').for(:cpf) }
    it { should_not allow_value('123456789').for(:cpf) }
    it { should validate_presence_of(:card_number) }
    it { should validate_presence_of(:card_holder) }
    it { should validate_presence_of(:expiry_date) }
    it { should validate_presence_of(:cvv) }
    it { should validate_uniqueness_of(:transaction_id).allow_nil }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 'pending', approved: 'approved', failed: 'failed') }
    it { should define_enum_for(:gateway_used).with_values(mercado_pago: 'mercado_pago', pag_seguro: 'pag_seguro') }
  end

  describe 'callbacks' do
    let(:payment) { create(:payment, card_number: '1234567890123456') }

    it 'masks the card number before save' do
      expect(payment.card_number).to eq('123456******3456')
    end

    it 'sets the last four digits of the card' do
      expect(payment.last_four_digits).to eq('3456')
    end
  end

  describe 'default scope' do
    let(:payment) { create(:payment) }

    it 'excludes sensitive fields like card_number' do
      result = Payment.first
      expect(result.attributes).not_to include('card_number')
    end
  end
end
