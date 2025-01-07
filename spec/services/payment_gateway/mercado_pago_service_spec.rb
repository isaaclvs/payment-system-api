require 'rails_helper'

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

  describe '#process_payment' do
    context 'when payment is successful' do
      let(:successful_response) do
        {
          'status' => 201,
          'response' => {
            'id' => 12345,
            'status' => 'approved'
          }
        }
      end

      before do
        allow(payment_client).to receive(:create).and_return(successful_response)
      end

      it 'returns success response' do
        result = service.process_payment
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Payment approved via Mercado Pago')
        expect(result[:transaction_id]).to eq(12345)
      end
    end

    context 'when payment is declined' do
      let(:failed_response) do
        {
          'status' => 400,
          'response' => {
            'message' => 'Invalid card number'
          }
        }
      end

      before do
        allow(payment_client).to receive(:create).and_return(failed_response)
      end

      it 'returns failure response' do
        result = service.process_payment
        
        expect(result[:success]).to be false
        expect(result[:message]).to include('Payment declined via Mercado Pago')
      end
    end

    context 'when API raises an error' do
      before do
        allow(payment_client).to receive(:create).and_raise(StandardError.new('API Error'))
      end

      it 'handles the error gracefully' do
        result = service.process_payment
        
        expect(result[:success]).to be false
        expect(result[:message]).to include('Error processing payment via Mercado Pago')
      end
    end
  end
end