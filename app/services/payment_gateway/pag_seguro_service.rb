module PaymentGateway
  class PagSeguroService
    def initialize(payment)
      @payment = payment
    end

    def process_payment
      if valid_card?
        { success: true, message: "Payment approved via PagSeguro" }
      else
        { success: false, message: "Payment declined via PagSeguro" }
      end
    end

    private

    def valid_card?
      @payment.card_number.length == 16
    end
  end
end