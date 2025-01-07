class PaymentService
  def initialize(payment_params)
    @payment_params = payment_params.except(:user)
    @user = payment_params[:user]
  end

  def process
    payment = @user.payments.new(@payment_params)
    
    return { success: false, message: payment.errors.full_messages.join(", ") } unless payment.valid?

    mercado_pago_result = PaymentGateway::MercadoPagoService.new(payment).process_payment
    
    if mercado_pago_result[:success]
      payment.status = 'approved'
      payment.gateway_used = 'mercado_pago'
      payment.transaction_id = mercado_pago_result[:transaction_id]
      payment.save
      return mercado_pago_result
    end

    payment.status = 'failed'
    payment.gateway_used = 'mercado_pago'
    payment.save
    mercado_pago_result
  end
end 