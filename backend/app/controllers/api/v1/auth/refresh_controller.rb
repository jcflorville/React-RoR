# frozen_string_literal: true

module Api
  module V1
    module Auth
      class RefreshController < ApplicationController
        include ApiResponse

        def create
          refresh_token = params[:refresh_token]

          result = ::Auth::TokenRefresher.call(refresh_token: refresh_token)

          if result.success?
            # Set access token in Authorization header (padrão Devise JWT)
            response.headers['Authorization'] = "Bearer #{result.data[:token]}"
            
            render json: {
              success: true,
              data: serialize_data(result.data[:user], blueprint: UserBlueprint),
              token: result.data[:token],
              refresh_token: result.data[:refresh_token],
              message: result.message
            }, status: :ok
          else
            render_error(result.message, result.errors, :unauthorized)
          end
        end
      end
    end
  end
end
