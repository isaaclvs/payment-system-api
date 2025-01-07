module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      def create
        build_resource(sign_up_params)
        
        if resource.save
          render json: {
            status: { code: 200, message: 'Signed up successfully.' },
            data: {
              user: {
                id: resource.id,
                email: resource.email,
                role: resource.role
              }
            }
          }, status: :ok
        else
          render json: {
            status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
          }, status: :unprocessable_entity
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :role)
      end
    end
  end
end