require 'rails_helper'
require_relative '../../../app/services/payment_gateway/mercado_pago_service'

RSpec.describe PaymentGateway::MercadoPagoService do
  let(:user) { create(:user) }
  let(:payment) { build(:payment, user: user, card_token: 'TEST-123456789') }
  let(:service) { described_class.new(payment) }
  let(:sdk_instance) { instance_double(Mercadopago::SDK) }
  let(:payment_client) { instance_double('PaymentClient') }

  before do
    allow(Mercadopago::SDK).to receive(:new).and_return(sdk_instance)
    allow(sdk_instance).to receive(:payment).and_return(payment_client)
  end

  context 'when payment is successful' do
    let(:successful_payment_response) do
      { 
        success: true, 
        message: "Payment approved via Mercado Pago",
        transaction_id: '123456789'
      }
    end

    it 'returns success response' do
      allow(payment_client).to receive(:create).and_return({
        response: { 
          'status' => 'approved',
          'id' => '123456789'
        }
      })

      result = service.process_payment
      expect(result[:success]).to be true
      expect(result[:message]).to eq('Payment approved via Mercado Pago')
    end
  end

  context 'when payment is declined' do
    let(:failed_payment_response) do
      { 
        success: false, 
        message: "Payment declined via Mercado Pago: declined"
      }
    end

    it 'returns failure response' do
      allow(payment_client).to receive(:create).and_return({
        response: { 
          'status' => 'rejected',
          'status_detail' => 'declined'
        }
      })

      result = service.process_payment
      expect(result[:success]).to be false
      expect(result[:message]).to include('Payment declined via Mercado Pago')
    end
  end
end