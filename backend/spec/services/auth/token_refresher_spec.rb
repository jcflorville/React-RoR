# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::TokenRefresher, type: :service do
  let(:user) { create(:user) }
  
  describe '#call' do
    context 'when refresh token is missing' do
      it 'returns failure' do
        result = described_class.call(refresh_token: nil)
        
        expect(result.success?).to be false
        expect(result.message).to eq('Refresh token is required')
        expect(result.errors).to include(:refresh_token)
      end
    end

    context 'when refresh token is invalid' do
      it 'returns failure with invalid token' do
        result = described_class.call(refresh_token: 'invalid-token')
        
        expect(result.success?).to be false
        expect(result.message).to eq('Invalid refresh token')
      end

      it 'returns failure when user not found' do
        payload = { refresh_jti: 'non-existent-jti', exp: 1.day.from_now.to_i }
        token = JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
        
        result = described_class.call(refresh_token: token)
        
        expect(result.success?).to be false
        expect(result.message).to eq('User not found or refresh token invalid')
      end
    end

    context 'when refresh token is expired' do
      it 'returns failure' do
        user.update!(refresh_jti: SecureRandom.uuid, refresh_token_expires_at: 1.day.ago)
        payload = { refresh_jti: user.refresh_jti, exp: 1.day.from_now.to_i }
        token = JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
        
        result = described_class.call(refresh_token: token)
        
        expect(result.success?).to be false
        expect(result.message).to eq('Refresh token expired')
      end
    end

    context 'when refresh token is valid' do
      before do
        user.generate_refresh_token!
      end

      it 'returns new tokens and user data' do
        payload = { 
          refresh_jti: user.refresh_jti, 
          sub: user.id,
          exp: user.refresh_token_expires_at.to_i 
        }
        refresh_token = JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
        
        result = described_class.call(refresh_token: refresh_token)
        
        expect(result.success?).to be true
        expect(result.message).to eq('Token refreshed successfully')
        expect(result.data).to include(:user, :token, :refresh_token)
        expect(result.data[:user]).to eq(user)
        expect(result.data[:token]).to be_present
        expect(result.data[:refresh_token]).to be_present
      end

      it 'generates new refresh_jti' do
        old_refresh_jti = user.refresh_jti
        
        payload = { 
          refresh_jti: old_refresh_jti, 
          sub: user.id,
          exp: user.refresh_token_expires_at.to_i 
        }
        refresh_token = JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
        
        result = described_class.call(refresh_token: refresh_token)
        
        user.reload
        expect(user.refresh_jti).not_to eq(old_refresh_jti)
        expect(result.success?).to be true
      end
    end
  end
end
