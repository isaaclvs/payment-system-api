module PaymentGateway
  class MercadoPagoService
    def initialize(payment)
      @payment = payment
      @sdk = Mercadopago::SDK.new(ENV['MercadoPago_ACCESS_TOKEN'])
    end

    def process_payment
      payment_data = {
        transaction_amount: @payment.amount.to_f,
        token: @payment.card_token,
        description: "Payment ID: #{@payment.id}",
        installments: 1,
        payment_method_id: detect_payment_method,
        payer: {
          email: @payment.user.email
        }
      }

      payment_response = @sdk.payment.create(payment_data)
      
      if payment_response['status'] == 201
        { 
          success: true, 
          message: "Payment approved via Mercado Pago",
          transaction_id: payment_response['response']['id']
        }
      else
        { 
          success: false, 
          message: "Payment declined via Mercado Pago: #{payment_response['response']['message']}"
        }
      end
    rescue => e
      { 
        success: false, 
        message: "Error processing payment via Mercado Pago: #{e.message}"
      }
    end

    private

    def detect_payment_method
      # Detect card type based on first digit
      case @payment.card_number[0]
      when '4'
        'visa'
      when '5'
        'master'
      when '3'
        if @payment.card_number.start_with?('34', '37')
          'amex'
        else
          'diners'
        end
      else
        'other'
      end
    end
  end
end