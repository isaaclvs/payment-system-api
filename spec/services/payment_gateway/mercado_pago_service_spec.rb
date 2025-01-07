require 'rails_helper'

RSpec.describe PaymentGateway::MercadoPagoService do
  let(:payment) { build(:payment) }
  let(:service) { described_class.new(payment) }

  describe '#process_payment' do
    context 'with valid card' do
      it 'returns success' do
        result = service.process_payment
        expect(result[:success]).to be true
        expect(result[:message]).to eq("Payment approved via Mercado Pago")
      end
    end

    context 'with invalid card' do
      let(:payment) { build(:payment, card_number: '5111111111111111') }
      
      it 'returns failure' do
        result = service.process_payment
        expect(result[:success]).to be false
        expect(result[:message]).to eq("Payment declined via Mercado Pago")
      end
    end
  end
end