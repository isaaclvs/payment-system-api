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
      if @payment[:card_token].nil?
        render json: { status: 'error', message: 'Card token is missing' }, status: :unprocessable_entity
        return
      end

      custom_headers = {
        'Authorization': "Bearer #{ENV['MercadoPago_ACCESS_TOKEN']}",
        'X-Idempotency-Key': "payment_#{@payment.id}_#{Time.now.to_i}"
      }

      request_options = Mercadopago::RequestOptions.new(custom_headers: custom_headers)

      payment_data = {
        transaction_amount: @payment.amount.to_f,
        token: @payment[:card_token],
        installments: 1,
        payer: {
          email: @payment.user.email
        },
        description: "Payment for Order ##{@payment.id}"
      }

      begin
        result = @sdk.payment.create(payment_data, request_options)
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
  end
end