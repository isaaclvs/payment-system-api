module PaymentGateway
  class MercadoPagoService
    def initialize(payment)
      @payment = payment
    end

    def process_payment
      sleep(1)
      success = rand < 0.7
      
      if success
        { success: true, message: 'Payment processed successfully with MercadoPago' }
      else
        { success: false, message: 'Payment failed with MercadoPago' }
      end
    end
  end
end