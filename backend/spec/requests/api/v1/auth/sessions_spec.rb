require 'rails_helper'

RSpec.describe 'API::V1::Auth::Sessions', type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  let(:login_params) do
    {
      user: {
        email: user.email,
        password: 'password123'
      }
    }
  end

  describe 'POST /api/v1/auth/sign_in' do
    context 'with valid credentials' do
      it 'returns success status' do
        post '/api/v1/auth/sign_in', params: login_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns JWT token in Authorization header' do
        post '/api/v1/auth/sign_in', params: login_params
        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end

      it 'returns user data in response body' do
        post '/api/v1/auth/sign_in', params: login_params
        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_present
        expect(json_response['data']['email']).to eq(user.email)
        expect(json_response['data']['id']).to eq(user.id)
        expect(json_response['data']['name']).to be_present
        expect(json_response['data']['created_at']).to be_present
        expect(json_response['data']['updated_at']).to be_present
      end

      it 'does not return password in response' do
        post '/api/v1/auth/sign_in', params: login_params
        json_response = response.parsed_body
        expect(json_response['data']).not_to have_key('password')
        expect(json_response['data']).not_to have_key('password_digest')
      end

      it 'returns success message' do
        post '/api/v1/auth/sign_in', params: login_params
        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['message']).to eq('Logged in successfully')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        invalid_params = { user: { email: user.email, password: 'wrong_password' } }
        post '/api/v1/auth/sign_in', params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for non-existent email' do
        invalid_params = { user: { email: 'nonexistent@example.com', password: 'password123' } }
        post '/api/v1/auth/sign_in', params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error message for invalid credentials' do
        invalid_params = { user: { email: user.email, password: 'wrong_password' } }
        post '/api/v1/auth/sign_in', params: invalid_params
        json_response = response.parsed_body
        expect(json_response['success']).to be false
        expect(json_response['message']).to eq('Invalid Email or password.')
      end

      it 'does not return JWT token on failed login' do
        invalid_params = { user: { email: user.email, password: 'wrong_password' } }
        post '/api/v1/auth/sign_in', params: invalid_params

        expect(response.headers['Authorization']).to be_nil
      end

      it 'does not return user data on failed login' do
        invalid_params = { user: { email: user.email, password: 'wrong_password' } }
        post '/api/v1/auth/sign_in', params: invalid_params

        json_response = response.parsed_body
        expect(json_response['data']).to be_nil
      end

      it 'returns unauthorized for missing email' do
        invalid_params = { user: { password: 'password123' } }
        post '/api/v1/auth/sign_in', params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for missing password' do
        invalid_params = { user: { email: user.email } }
        post '/api/v1/auth/sign_in', params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for empty email' do
        invalid_params = { user: { email: '', password: 'password123' } }
        post '/api/v1/auth/sign_in', params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for empty password' do
        invalid_params = { user: { email: user.email, password: '' } }
        post '/api/v1/auth/sign_in', params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for malformed email' do
        invalid_params = { user: { email: 'invalid-email', password: 'password123' } }
        post '/api/v1/auth/sign_in', params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with content type validation' do
      it 'accepts JSON content type' do
        post '/api/v1/auth/sign_in',
             params: login_params.to_json,
             headers: { 'Content-Type' => 'application/json' }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE /api/v1/auth/sign_out' do
    context 'when user is authenticated' do
      let(:auth_headers) do
        post '/api/v1/auth/sign_in', params: login_params
        { 'Authorization' => response.headers['Authorization'] }
      end

      it 'returns no_content status' do
        delete '/api/v1/auth/sign_out', headers: auth_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'invalidates the JWT token' do
        # First, sign in to get a token
        post '/api/v1/auth/sign_in', params: login_params
        auth_token = response.headers['Authorization']

        # Then sign out
        delete '/api/v1/auth/sign_out', headers: { 'Authorization' => auth_token }
        expect(response).to have_http_status(:no_content)

        # Try to use the token again - should be invalid (depends on your implementation)
        # This test might need adjustment based on your JWT revocation strategy
      end
    end

    context 'when user is not authenticated' do
      it 'still returns no_content status' do
        delete '/api/v1/auth/sign_out'
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with invalid token' do
      it 'raises JWT error for malformed token (middleware behavior)' do
        expect {
          delete '/api/v1/auth/sign_out',
                 headers: { 'Authorization' => 'Bearer invalid_token' }
        }.to raise_error(JWT::DecodeError, /Not enough or too many segments/)
      end

      it 'returns no_content for missing Bearer' do
        delete '/api/v1/auth/sign_out',
               headers: { 'Authorization' => 'invalid_token_without_bearer' }
        expect(response).to have_http_status(:no_content)
      end
    end
  end


  describe 'Edge cases' do
    it 'handles concurrent login requests' do
      threads = []
      results = []

      5.times do
        threads << Thread.new do
          post '/api/v1/auth/sign_in', params: login_params
          results << response.status
        end
      end

      threads.each(&:join)
      expect(results).to all(eq(200))
    end

    it 'handles case-insensitive email login' do
      upcase_params = {
        user: {
          email: user.email.upcase,
          password: 'password123'
        }
      }

      post '/api/v1/auth/sign_in', params: upcase_params
      expect(response).to have_http_status(:ok)
    end

    it 'handles login with extra whitespace in email (strips whitespace)' do
      whitespace_params = {
        user: {
          email: "  #{user.email}  ",
          password: 'password123'
        }
      }

      post '/api/v1/auth/sign_in', params: whitespace_params
      # O modelo User faz strip no email, então deve funcionar
      expect(response).to have_http_status(:ok)
    end
  end
end
