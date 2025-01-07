require 'rails_helper'

RSpec.describe "Api::V1::Payments", type: :request do
  let(:user) { create(:user) }
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
  let(:headers) do
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end

  describe "POST /api/v1/payments" do
    let(:payment_params) do
      {
        payment: {
          amount: 100.00,
          card_number: '4235647728025682',
          card_holder: 'APRO',
          expiry_date: '12/25',
          cvv: '123',
          card_token: 'TEST-123456789'
        }
      }
    end

    context 'when payment is successful' do
      before do
        sdk_double = double('sdk')
        payment_double = double('payment')
        
        allow(Mercadopago::SDK).to receive(:new).and_return(sdk_double)
        allow(sdk_double).to receive(:payment).and_return(payment_double)
        allow(payment_double).to receive(:create).and_return({
          response: {
            'status' => 'approved',
            'id' => '12345',
            'status_detail' => 'accredited'
          }
        })
      end

      it 'creates a payment and returns success' do
        expect {
          post '/api/v1/payments', params: payment_params.to_json, headers: headers
        }.to change(Payment, :count).by(1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        expect(json['message']).to eq('Payment approved via Mercado Pago')
      end
    end

    context 'when payment fails' do
      before do
        sdk_double = double('sdk')
        payment_double = double('payment')
        
        allow(Mercadopago::SDK).to receive(:new).and_return(sdk_double)
        allow(sdk_double).to receive(:payment).and_return(payment_double)
        allow(payment_double).to receive(:create).and_return({
          response: {
            'status' => 'rejected',
            'status_detail' => 'cc_rejected_other_reason'
          }
        })
      end

      it 'saves the failed payment and returns error' do
        expect {
          post '/api/v1/payments', params: payment_params.to_json, headers: headers
        }.to change(Payment, :count).by(1)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['message']).to include('Payment declined')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        post '/api/v1/payments', params: payment_params.to_json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end 