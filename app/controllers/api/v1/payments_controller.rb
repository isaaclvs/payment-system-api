module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :authenticate_user!
      before_action :check_admin, only: [:index]

      def create
        payment = current_user.payments.new(payment_params)
        service = PaymentService.new(payment_params.merge(user: current_user))
        result = service.process

        if result[:success]
          last_four_digits = payment.card_number.last(4)
          masked_expiry_date = "#{payment.expiry_date[0..1]}/**"

          render json: {
            status: 'success',
            message: result[:message],
            payment: PaymentSerializer.new(payment).serializable_hash[:data][:attributes].merge(
              last_four_digits: last_four_digits,
              expiry_date: masked_expiry_date,
              cpf: payment.cpf || 'N/A'
            )
          }, status: :ok
        else
          render json: {
            status: 'failed',
            message: result[:message],
            payment: PaymentSerializer.new(payment).serializable_hash[:data][:attributes].merge(
              last_four_digits: last_four_digits,
              expiry_date: masked_expiry_date,
              cpf: payment.cpf || 'N/A'
            )
          }, status: :unprocessable_entity
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
          :cpf
        )
      end

      def check_admin
        unless current_user.admin?
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
    end
  end
end 