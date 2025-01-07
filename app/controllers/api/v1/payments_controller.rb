module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :authenticate_user!
      before_action :check_admin, only: [:index]

      def create
        payment = current_user.payments.new(payment_params)

        service = PaymentGateway::MercadoPagoService.new(payment)
        card_token = service.generate_card_token

        if card_token.nil?
          render json: { status: 'error', message: 'Failed to generate card token' }, status: :unprocessable_entity
          return
        end

        payment.update(card_token: card_token)
        
        if payment.save
          result = service.process_payment

          if result[:success]
            last_four_digits = payment.card_number.last(4)
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
            payment.update(
              status: 'failed',
              gateway_used: 'mercado_pago'
            )

            render json: {
              status: 'error',
              message: result[:message]
            }, status: :unprocessable_entity
          end
        else
          render json: {
            status: 'error',
            message: payment.errors.full_messages.join(', ')
          }, status: :unprocessable_entity
        end
      end

      def index
        payments = current_user.admin? ? Payment.all : current_user.payments
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
    end
  end
end 