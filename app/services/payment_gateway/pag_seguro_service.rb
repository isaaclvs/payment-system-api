module PaymentGateway
  class PagSeguroService
    def initialize(payment)
      @payment = payment
    end

    def process_payment
      sleep(1)
      success = rand < 0.8
      
      if success
        { success: true, message: 'Payment processed successfully with PagSeguro' }
      else
        { success: false, message: 'Payment failed with PagSeguro' }
      end
    end
  end
end