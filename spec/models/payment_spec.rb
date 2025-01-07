require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:card_number) }
    it { should validate_presence_of(:card_holder) }
    it { should validate_presence_of(:expiry_date) }
    it { should validate_presence_of(:cvv) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'status' do
    let(:payment) { create(:payment) }

    it 'defaults to pending' do
      expect(payment.status).to eq('pending')
    end

    it 'can be approved' do
      payment.update(status: 'approved')
      expect(payment.status).to eq('approved')
    end

    it 'can be failed' do
      payment.update(status: 'failed')
      expect(payment.status).to eq('failed')
    end
  end

  describe 'gateway_used' do
    it 'can be mercado_pago' do
      payment = create(:payment, :approved)
      expect(payment.gateway_used).to eq('mercado_pago')
    end

    it 'can be pag_seguro' do
      payment = create(:payment, :failed)
      expect(payment.gateway_used).to eq('pag_seguro')
    end
  end
end
