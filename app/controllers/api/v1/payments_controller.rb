module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :authenticate_user!
      before_action :check_admin, only: [:index]

      def create
        payment = current_user.payments.new(payment_params)

        last_four_digits = payment.card_number.last(4)

        service = PaymentService.new(payment_params.merge(user: current_user))
        result = service.process

        if result[:success]

          masked_expiry_date = "#{payment.expiry_date[0..1]}/**"

          payment.update(
            status: 'approved',
            gateway_used: 'mercado_pago',
            transaction_id: result[:transaction_id],
            last_four_digits: last_four_digits,
            expiry_date: masked_expiry_date
          )

          render json: {
            status: 'success',
            message: result[:message],
            payment: PaymentSerializer.new(payment).serializable_hash[:data][:attributes].merge(
              last_four_digits: last_four_digits,
              expiry_date: masked_expiry_date
            )
          }, status: :ok
        else
          handle_pagseguro_fallback(payment)
        end
      end
     
      def index
        payments = current_user.admin? ? Payment.select('*') : current_user.payments.select('*')
        render json: PaymentSerializer.new(payments).serializable_hash[:data].map { |p| p[:attributes] }
      end 
      
      private

      def payment_params
        params.require(:payment).permit(
          :amount,
          :card_number,
          :card_holder,
          :expiry_date,
          :cvv,
          :card_token
        )
      end

      def check_admin
        unless current_user.admin?
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def handle_pagseguro_fallback(payment)
        service_pagseguro = PaymentGateway::PagSeguroService.new(payment)
        result_pagseguro = service_pagseguro.process_payment

        if result_pagseguro[:success]
          last_four_digits = payment.card_number.last(4)
          masked_expiry_date = "#{payment.expiry_date[0..1]}/**"

          payment.update(
            status: 'approved',
            gateway_used: 'pag_seguro',
            transaction_id: result_pagseguro[:transaction_id],
            last_four_digits: last_four_digits,
            expiry_date: masked_expiry_date
          )

          render json: {
            status: 'success',
            message: result_pagseguro[:message],
            payment: PaymentSerializer.new(payment).serializable_hash[:data][:attributes].merge(
              last_four_digits: last_four_digits,
              expiry_date: masked_expiry_date
            )
          }, status: :ok
        else
          payment.update(status: 'failed', gateway_used: 'pag_seguro')

          render json: {
            status: 'error',
            message: result_pagseguro[:message]
          }, status: :unprocessable_entity
        end
      end
    end
  end
end 