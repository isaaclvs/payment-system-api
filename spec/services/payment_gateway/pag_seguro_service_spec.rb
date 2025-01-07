require 'rails_helper'

RSpec.describe PaymentGateway::PagSeguroService do
  let(:payment) { build(:payment) }
  let(:service) { described_class.new(payment) }

  describe '#process_payment' do
    context 'with valid card length' do
      it 'returns success' do
        result = service.process_payment
        expect(result[:success]).to be true
        expect(result[:message]).to eq("Payment approved via PagSeguro")
      end
    end

    context 'with invalid card length' do
      let(:payment) { build(:payment, card_number: '41111') }
      
      it 'returns failure' do
        result = service.process_payment
        expect(result[:success]).to be false
        expect(result[:message]).to eq("Payment declined via PagSeguro")
      end
    end
  end
end