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
      payment.save
      return mercado_pago_result
    end

    pag_seguro_result = PaymentGateway::PagSeguroService.new(payment).process_payment
    
    if pag_seguro_result[:success]
      payment.status = 'approved'
      payment.gateway_used = 'pag_seguro'
    else
      payment.status = 'failed'
      payment.gateway_used = 'pag_seguro'
    end

    payment.save
    pag_seguro_result
  end
end 