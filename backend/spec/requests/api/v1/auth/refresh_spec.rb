# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Refresh', type: :request do
  let(:user) { create(:user) }

  describe 'POST /api/v1/auth/refresh' do
    context 'when refresh token is valid' do
      before do
        user.generate_refresh_token!
      end

      it 'returns new access and refresh tokens' do
        payload = { 
          refresh_jti: user.refresh_jti, 
          sub: user.id,
          exp: user.refresh_token_expires_at.to_i 
        }
        refresh_token = JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')

        post '/api/v1/auth/refresh', params: { refresh_token: refresh_token }

        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be true
        expect(json_response['data']).to include('id', 'email', 'name')
        expect(json_response['token']).to be_present
        expect(json_response['refresh_token']).to be_present
        expect(json_response['message']).to eq('Token refreshed successfully')
      end

      it 'updates user refresh_jti' do
        old_refresh_jti = user.refresh_jti
        
        payload = { 
          refresh_jti: old_refresh_jti, 
          sub: user.id,
          exp: user.refresh_token_expires_at.to_i 
        }
        refresh_token = JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')

        post '/api/v1/auth/refresh', params: { refresh_token: refresh_token }

        user.reload
        expect(user.refresh_jti).not_to eq(old_refresh_jti)
      end
    end

    context 'when refresh token is missing' do
      it 'returns error' do
        post '/api/v1/auth/refresh', params: { refresh_token: '' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['success']).to be false
        expect(json_response['message']).to eq('Refresh token is required')
      end
    end

    context 'when refresh token is invalid' do
      it 'returns error' do
        post '/api/v1/auth/refresh', params: { refresh_token: 'invalid-token' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['success']).to be false
        expect(json_response['message']).to eq('Invalid refresh token')
      end
    end

    context 'when refresh token is expired' do
      before do
        user.update!(refresh_jti: SecureRandom.uuid, refresh_token_expires_at: 1.day.ago)
      end

      it 'returns error' do
        payload = { 
          refresh_jti: user.refresh_jti, 
          sub: user.id,
          exp: 1.day.from_now.to_i 
        }
        refresh_token = JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')

        post '/api/v1/auth/refresh', params: { refresh_token: refresh_token }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['success']).to be false
        expect(json_response['message']).to eq('Refresh token expired')
      end
    end

    context 'when user does not exist' do
      it 'returns error' do
        payload = { 
          refresh_jti: SecureRandom.uuid, 
          sub: 99999,
          exp: 1.day.from_now.to_i 
        }
        refresh_token = JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')

        post '/api/v1/auth/refresh', params: { refresh_token: refresh_token }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['success']).to be false
      end
    end
  end
end
