module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json
      skip_before_action :verify_signed_out_user
      
      private

      def respond_with(resource, _opts = {})
        render json: {
          status: { code: 200, message: 'Logged in successfully.' },
          data: {
            user: {
              id: resource.id,
              email: resource.email,
              role: resource.role
            }
          }
        }, status: :ok
      end

      def respond_to_on_destroy
        render json: {
          status: 200,
          message: 'Logged out successfully.'
        }, status: :ok
      end
    end
  end
end