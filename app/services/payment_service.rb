class PaymentService
  # Initializes the service with payment parameters and user information
  def initialize(payment_params)
    @payment_params = payment_params.except(:user)
    @user = payment_params[:user]
  end

  # Main method to process the payment
  def process
    payment = @user.payments.new(@payment_params)
    
    # If the payment is invalid, return error message
    return { success: false, message: payment.errors.full_messages.join(", ") } unless payment.valid?

    # Attempt to process payment via PagSeguro service
    pagseguro_result = PaymentGateway::PagSeguroService.new(payment).process_payment

    if pagseguro_result[:success]
      payment.status = 'approved'
      payment.gateway_used = 'pag_seguro'
      payment.transaction_id = pagseguro_result[:transaction_id]
      payment.save

      pagseguro_result
    else
      # If PagSeguro fails, attempt payment via Mercado Pago service
      mercado_pago_result = PaymentGateway::MercadoPagoService.new(payment).process_payment

      if mercado_pago_result[:success]
        payment.status = 'approved'
        payment.gateway_used = 'mercado_pago'
        payment.transaction_id = mercado_pago_result[:transaction_id]
        payment.save

        mercado_pago_result
      else
        payment.status = 'failed'
        payment.save
        mercado_pago_result
      end
    end
  end
end 