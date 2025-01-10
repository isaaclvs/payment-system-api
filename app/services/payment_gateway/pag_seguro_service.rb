require 'httparty'

module PaymentGateway
  class PagSeguroService
    include HTTParty

    # Initializes the service with payment data
    def initialize(payment)
      @payment = payment
    end

    # Main method to process payment by creating an order and then paying for it
    def process_payment
      # Create the order on PagSeguro
      order_response = create_order(@payment)
      return { success: false, message: 'Order creation failed' } unless order_response[:success]

      # Pay for the created order only if the status is "AUTHORIZED"
      order_id = order_response[:order_id]
      order_status = order_response[:status]

      binding.pry
      return { success: false, message: 'Order not authorized for payment' } unless order_status == 'PAID'

      # Pay for the created order
      payment_response = pay_for_order(order_id, @payment)

      if payment_response[:success]
        { success: true, message: 'Payment approved via PagSeguro' }
      else
        { success: false, message: payment_response[:message] }
      end
    end

    private

    # Creates an order on PagSeguro's API
    def create_order(payment)
      response = HTTParty.post(
        'https://sandbox.api.pagseguro.com/orders',
        headers: headers,
        body: order_data(payment).to_json,
        timeout: 30
      )

      if response.code == 201
        # Parse and return order_id from response body
        response_data = response.parsed_response
        order_status = response_data.dig('charges', 0, 'status')
        { success: true, order_id: response_data['id'], status: order_status }
      else
        { success: false, message: "Failed to create order: #{response.body}" }
      end
    end

    # Processes the payment for the created order
    def pay_for_order(order_id, payment)
      response = HTTParty.post("https://sandbox.api.pagseguro.com/orders/#{order_id}/pay", headers: headers,
                                                                                           body: payment_data(payment).to_json)
      binding.pry
      if response.code == 201
        charge_status = response.parsed_response.dig('charges', 0, 'status')
        if charge_status == 'PAID'
          { success: true, message: 'Payment successfully processed' }
        else
          { success: false, message: "Payment declined: #{charge_status}" }
        end
      else
        { success: false, message: "Failed to process payment: #{response.body}" }
      end
    end

    # Returns the necessary headers for the API requests
    def headers
      {
        'Authorization' => "Bearer #{ENV['PagSeguro_ACCESS_TOKEN']}",
        'Content-Type' => 'application/json'
      }
    end

    # Extracts expiration month and year from the expiry date
    def extract_expiration_date(expiry_date)
      expiration_month, expiration_year = expiry_date.split('/').map(&:to_i)
      expiration_year += 2000 # Add "2000" to the year to make it complete (e.g., 25 -> 2025)

      @expiration_month = expiration_month
      @expiration_year = expiration_year
    end

    # Prepares the order data to be sent to PagSeguro API
    def order_data(payment)
      extract_expiration_date(payment.expiry_date)

      {
        reference_id: "order_#{SecureRandom.hex(10)}",
        customer: {
          name: payment.card_holder,
          email: 'email@test.com',
          tax_id: payment.cpf,
          phones: [
            {
              country: 55,
              area: 11,
              number: 999_999_999,
              type: 'MOBILE'
            }
          ]
        },
        items: [
          {
            reference_id: "item_#{SecureRandom.hex(10)}",
            name: 'Air Force 1',
            quantity: 1,
            unit_amount: 1000
          }
        ],
        charges: [
          {
            reference_id: "charge_#{SecureRandom.hex(10)}",
            description: 'Cartão de Crédito',
            amount: {
              value: 1000,
              currency: 'BRL'
            },
            payment_method: {
              type: 'CREDIT_CARD',
              installments: 1,
              capture: true,
              soft_descriptor: 'Minha Loja',
              card: {
                number: payment.card_number,
                exp_month: @expiration_month,
                exp_year: @expiration_year,
                security_code: payment.cvv,
                holder: {
                  name: payment.card_holder,
                  tax_id: payment.cpf
                }
              }
            }
          }
        ]
      }
    end

    # Prepares the payment data to be sent to PagSeguro API
    def payment_data(payment)
      extract_expiration_date(payment.expiry_date)

      {
        charges: [
          {
            reference_id: "payment_#{SecureRandom.hex(10)}",
            description: 'Cartao de credito',
            amount: {
              value: 1000,
              currency: 'BRL'
            },
            payment_method: {
              type: 'CREDIT_CARD',
              installments: 1,
              capture: true,
              soft_descriptor: 'Minha Loja',
              card: {
                number: payment.card_number,
                exp_month: @expiration_month,
                exp_year: @expiration_year,
                security_code: payment.cvv,
                holder: {
                  name: payment.card_holder,
                  tax_id: payment.cpf
                }
              }
            }
          }
        ]
      }
    end
  end
end
