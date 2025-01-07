module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :authenticate_user!
      before_action :check_admin, only: [:index]

      def create
        service = PaymentService.new(payment_params.merge(user: current_user))
        result = service.process

        if result[:success]
          render json: { 
            status: 'success', 
            message: result[:message],
            payment: PaymentSerializer.new(Payment.last).serializable_hash[:data][:attributes]
          }, status: :ok
        else
          render json: { status: 'error', message: result[:message] }, status: :unprocessable_entity
        end
      end

      def index
        payments = current_user.admin? ? Payment.all : current_user.payments
        render json: PaymentSerializer.new(payments).serializable_hash[:data].map { |p| p[:attributes] }
      end

      private

      def payment_params
        params.require(:payment).permit(:amount, :card_number, :card_holder, :expiry_date, :cvv)
      end

      def check_admin
        unless current_user.admin?
          render json: { error: 'Unauthorized. Admin access required.' }, status: :unauthorized
        end
      end
    end
  end
end 