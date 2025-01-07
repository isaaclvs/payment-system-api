module PaymentGateway
  class MercadoPagoService
    def initialize(payment)
      @payment = payment
    end

    def process_payment
      if valid_card?
        { success: true, message: "Payment approved via Mercado Pago" }
      else
        { success: false, message: "Payment declined via Mercado Pago" }
      end
    end

    private

    def valid_card?
      @payment.card_number.start_with?('4')
    end
  end
end