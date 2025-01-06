class PaymentService
  def initialize(payment_params)
    @payment_params = payment_params
    @payment = nil
  end

  def process
    create_payment
    process_payment
  rescue StandardError => e
    @payment&.update(status: 'failed')
    { success: false, message: e.message }
  end

  private

  def create_payment
    @payment = Payment.new(@payment_params)
    @payment.last_four_digits = @payment_params[:card_number].last(4)
    @payment.save!
  end

  def process_payment
    begin
      result = process_with_mercado_pago
      return result if result[:success]
      
      # If MercadoPago fails, try PagSeguro
      process_with_pagseguro
    rescue StandardError => e
      @payment.update(status: 'failed')
      { success: false, message: 'All payment attempts failed' }
    end
  end

  def process_with_mercado_pago
    # Simulate MercadoPago API call
    success = rand > 0.5 # 50% success rate
    
    if success
      @payment.update(gateway_used: 'mercado_pago', status: 'success')
      { success: true, message: 'Payment processed successfully via MercadoPago' }
    else
      @payment.update(status: 'processing')
      { success: false, message: 'MercadoPago payment failed' }
    end
  end

  def process_with_pagseguro
    # Simulate PagSeguro API call
    success = rand > 0.3 # 70% success rate
    
    if success
      @payment.update(gateway_used: 'pagseguro', status: 'success')
      { success: true, message: 'Payment processed successfully via PagSeguro' }
    else
      @payment.update(status: 'failed', gateway_used: 'pagseguro')
      { success: false, message: 'Payment processing failed' }
    end
  end
end 