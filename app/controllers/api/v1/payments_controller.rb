module Api
  module V1
    class PaymentsController < ApplicationController
      def create
        service = PaymentService.new(payment_params)
        result = service.process

        if result[:success]
          render json: { status: 'success', message: result[:message] }, status: :ok
        else
          render json: { status: 'error', message: result[:message] }, status: :unprocessable_entity
        end
      end

      def index
        payments = Payment.all
        render json: payments
      end

      private

      def payment_params
        params.require(:payment).permit(:amount, :card_number, :card_holder, :expiry_date, :cvv)
      end
    end
  end
end 