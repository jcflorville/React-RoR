# frozen_string_literal: true

module Auth
  class TokenRefresher < BaseService
    def self.call(refresh_token:)
      new(refresh_token: refresh_token).call
    end

    def initialize(refresh_token:)
      @refresh_token = refresh_token
    end

    def call
      return failure(message: "Refresh token is required", errors: { refresh_token: ["can't be blank"] }) if @refresh_token.blank?

      decoded_token = decode_refresh_token
      return failure(message: "Invalid refresh token", errors: { refresh_token: ["is invalid or expired"] }) unless decoded_token

      user = find_user(decoded_token)
      return failure(message: "User not found or refresh token invalid", errors: { refresh_token: ["is invalid"] }) unless user

      # Validate refresh token
      unless user.refresh_token_valid?
        return failure(message: "Refresh token expired", errors: { refresh_token: ["has expired"] })
      end

      # Generate new access token
      token = generate_access_token(user)
      
      # Generate new refresh token
      user.generate_refresh_token!
      new_refresh_token = generate_refresh_token(user)

      success(
        data: {
          user: user,
          token: token,
          refresh_token: new_refresh_token
        },
        message: "Token refreshed successfully"
      )
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      failure(message: "Invalid or expired refresh token", errors: { refresh_token: [e.message] })
    end

    private

    def decode_refresh_token
      JWT.decode(
        @refresh_token,
        ENV['DEVISE_JWT_SECRET_KEY'],
        true,
        { algorithm: 'HS256', verify_expiration: true }
      ).first
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    def find_user(decoded_token)
      refresh_jti = decoded_token['refresh_jti']
      return nil unless refresh_jti

      User.find_by(refresh_jti: refresh_jti)
    end

    def generate_access_token(user)
      payload = {
        sub: user.id,
        jti: user.jti,
        exp: 15.minutes.from_now.to_i,
        iat: Time.current.to_i
      }
      
      JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
    end

    def generate_refresh_token(user)
      payload = {
        sub: user.id,
        refresh_jti: user.refresh_jti,
        exp: user.refresh_token_expires_at.to_i,
        iat: Time.current.to_i,
        type: 'refresh'
      }
      
      JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
    end
  end
end
