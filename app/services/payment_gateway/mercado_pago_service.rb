require 'mercadopago'
require 'httparty'

module PaymentGateway
  class MercadoPagoService
    include HTTParty

    def initialize(payment)
      @payment = payment
      @sdk = Mercadopago::SDK.new(ENV['MercadoPago_ACCESS_TOKEN'])
    end

    def process_payment
      @card_token = generate_card_token

      if @card_token.nil?
        render json: { status: 'error', message: 'Failed to generate card token' }, status: :unprocessable_entity
        return
      end

      custom_headers = {
        'Authorization': "Bearer #{ENV['MercadoPago_ACCESS_TOKEN']}",
        'X-Idempotency-Key': "payment_#{@payment.id}_#{Time.now.to_i}"
      }

      request_options = Mercadopago::RequestOptions.new(custom_headers: custom_headers)

      payment_data = {
        transaction_amount: @payment.amount.to_f,
        token: @card_token,
        installments: 1,
        payer: {
          email: @payment.user.email
        }
      }

      begin
        result = @sdk.payment.create(payment_data)
        payment_response = result[:response]
        
        if payment_response['status'] == 'approved'
          { 
            success: true, 
            message: "Payment approved via Mercado Pago",
            transaction_id: payment_response['id']
          }
        else
          { 
            success: false, 
            message: "Payment declined via Mercado Pago: #{payment_response['status_detail']}"
          }
        end
      rescue => e
        { 
          success: false, 
          message: "Error processing payment via Mercado Pago: #{e.message}"
        }
      end
    end
    
    def generate_card_token
      url = 'https://api.mercadopago.com/v1/card_tokens'
      headers = {
        'Authorization' => "Bearer #{ENV['MercadoPago_ACCESS_TOKEN']}",
        'Content-Type' => 'application/json'
      }

      # Extract card validity month and year
      @expiration_month, @expiration_year = @payment.expiry_date.split('/').map(&:to_i)
      @expiration_year += 2000 # Add "2000" to the year to make it complete (e.g., 25 -> 2025)

      body = {
        card_number: @payment.card_number,
        expiration_month: @expiration_month,
        expiration_year: @expiration_year,
        security_code: @payment.cvv,
        cardholder: {
          name: @payment.card_holder
        }
      }

      response = HTTParty.post(url, headers: headers, body: body.to_json, timeout: 30)

      if response.code == 201
        card_token = response.parsed_response['id'] # Card Token
        @payment.update!(card_token: card_token)
        card_token
      else
        Rails.logger.error "Error generating card token: #{response.body}"
        nil
      end
    end
  end
end