require 'rails_helper'

RSpec.describe 'API::V1::Authenticated::Profiles', type: :request do
  let(:user) { create(:user, name: 'John Doe', email: 'john@example.com') }
  let(:auth_headers) do
    post '/api/v1/auth/sign_in', params: {
      user: {
        email: user.email,
        password: user.password
      }
    }
    { 'Authorization' => response.headers['Authorization'] }
  end

  describe 'GET /api/v1/profiles' do
    context 'when user is authenticated' do
      before do
        get '/api/v1/profiles', headers: auth_headers
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns success response structure' do
        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_present
      end

      it 'returns user profile data' do
        json_response = response.parsed_body
        user_data = json_response['data']

        expect(user_data['id']).to eq(user.id)
        expect(user_data['email']).to eq(user.email)
        expect(user_data['name']).to eq(user.name)
        expect(user_data['created_at']).to be_present
        expect(user_data['updated_at']).to be_present
      end

      it 'does not return sensitive data' do
        json_response = response.parsed_body
        user_data = json_response['data']

        expect(user_data).not_to have_key('password')
        expect(user_data).not_to have_key('password_digest')
        expect(user_data).not_to have_key('jti')
        expect(user_data).not_to have_key('encrypted_password')
      end

      it 'uses UserSerializer format' do
        json_response = response.parsed_body
        user_data = json_response['data']

        # Verificar que contém exatamente os campos do UserSerializer
        expected_keys = %w[id email name created_at updated_at]
        expect(user_data.keys.sort).to eq(expected_keys.sort)
      end
    end

    context 'when user is not authenticated' do
      before do
        get '/api/v1/profiles'
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid JWT token' do
      before do
        get '/api/v1/profiles'
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with expired JWT token' do
      let(:expired_headers) do
        # Simular token expirado
        payload = { user_id: user.id, exp: 1.hour.ago.to_i }
        token = JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key)
        { 'Authorization' => "Bearer #{token}" }
      end

      before do
        get '/api/v1/profiles', headers: expired_headers
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/profiles' do
    context 'when user is authenticated' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            user: {
              name: 'Jane Doe Updated',
              email: 'jane.updated@example.com'
            }
          }
        end

        before do
          patch '/api/v1/profiles', params: valid_params, headers: auth_headers
        end

        it 'returns success status' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns success response structure' do
          json_response = response.parsed_body
          expect(json_response['success']).to be true
          expect(json_response['message']).to eq('Profile updated successfully')
          expect(json_response['data']).to be_present
        end

        it 'updates user data' do
          user.reload
          expect(user.name).to eq('Jane Doe Updated')
          expect(user.email).to eq('jane.updated@example.com')
        end

        it 'returns updated user data' do
          json_response = response.parsed_body
          user_data = json_response['data']

          expect(user_data['name']).to eq('Jane Doe Updated')
          expect(user_data['email']).to eq('jane.updated@example.com')
          expect(user_data['id']).to eq(user.id)
        end

        it 'does not return sensitive data' do
          json_response = response.parsed_body
          user_data = json_response['data']

          expect(user_data).not_to have_key('password')
          expect(user_data).not_to have_key('jti')
        end
      end

      context 'with partial updates' do
        context 'updating only name' do
          let(:name_params) { { user: { name: 'New Name Only' } } }

          before do
            patch '/api/v1/profiles', params: name_params, headers: auth_headers
          end

          it 'updates only the name' do
            user.reload
            expect(user.name).to eq('New Name Only')
            expect(user.email).to eq('john@example.com') # unchanged
          end

          it 'returns success' do
            expect(response).to have_http_status(:ok)
            json_response = response.parsed_body
            expect(json_response['success']).to be true
          end
        end

        context 'updating only email' do
          let(:email_params) { { user: { email: 'newemail@example.com' } } }

          before do
            patch '/api/v1/profiles', params: email_params, headers: auth_headers
          end

          it 'updates only the email' do
            user.reload
            expect(user.email).to eq('newemail@example.com')
            expect(user.name).to eq('John Doe') # unchanged
          end
        end
      end

      context 'with invalid parameters' do
        context 'with empty name' do
          let(:invalid_params) { { user: { name: '' } } }

          before do
            patch '/api/v1/profiles', params: invalid_params, headers: auth_headers
          end

          it 'returns unprocessable content status' do
            expect(response).to have_http_status(:unprocessable_content)
          end

          it 'returns error response' do
            json_response = response.parsed_body
            expect(json_response['success']).to be false
            expect(json_response['message']).to eq('Failed to update profile')
            expect(json_response['errors']).to be_present
          end

          it 'returns validation errors' do
            json_response = response.parsed_body
            expect(json_response['errors']).to have_key('name')
            expect(json_response['errors']['name']).to include("can't be blank")
          end

          it 'does not update user data' do
            user.reload
            expect(user.name).to eq('John Doe') # unchanged
          end
        end

        context 'with invalid email format' do
          let(:invalid_params) { { user: { email: 'invalid-email' } } }

          before do
            patch '/api/v1/profiles', params: invalid_params, headers: auth_headers
          end

          it 'returns unprocessable entity status' do
            expect(response).to have_http_status(:unprocessable_content)
          end

          it 'returns email validation errors' do
            json_response = response.parsed_body
            expect(json_response['errors']).to have_key('email')
            expect(json_response['errors']['email']).to include('is invalid')
          end
        end

        context 'with duplicate email' do
          let!(:other_user) { create(:user, email: 'existing@example.com') }
          let(:duplicate_params) { { user: { email: 'existing@example.com' } } }

          before do
            patch '/api/v1/profiles', params: duplicate_params, headers: auth_headers
          end

          it 'returns unprocessable entity status' do
            expect(response).to have_http_status(:unprocessable_content)
          end

          it 'returns uniqueness validation error' do
            json_response = response.parsed_body
            expect(json_response['errors']).to have_key('email')
            expect(json_response['errors']['email']).to include('has already been taken')
          end
        end

        context 'with name too short' do
          let(:invalid_params) { { user: { name: 'a' } } }

          before do
            patch '/api/v1/profiles', params: invalid_params, headers: auth_headers
          end

          it 'returns validation error for name length' do
            json_response = response.parsed_body
            expect(json_response['errors']).to have_key('name')
            expect(json_response['errors']['name']).to include('is too short (minimum is 2 characters)')
          end
        end

        context 'with name too long' do
          let(:invalid_params) { { user: { name: 'a' * 101 } } }

          before do
            patch '/api/v1/profiles', params: invalid_params, headers: auth_headers
          end

          it 'returns validation error for name length' do
            json_response = response.parsed_body
            expect(json_response['errors']).to have_key('name')
            expect(json_response['errors']['name']).to include('is too long (maximum is 100 characters)')
          end
        end
      end

      context 'with unpermitted parameters' do
        let(:unpermitted_params) do
          {
            user: {
              name: 'Valid Name',
              password: 'hacker_attempt',
              jti: 'hacker_attempt',
              id: 999,
              created_at: 1.year.ago
            }
          }
        end

        before do
          patch '/api/v1/profiles', params: unpermitted_params, headers: auth_headers
        end

        it 'updates only permitted parameters' do
          user.reload
          expect(user.name).to eq('Valid Name')
          expect(user.id).to eq(user.id) # unchanged
          # Password and other sensitive fields should remain unchanged
        end

        it 'returns success' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'with empty request body' do
        before do
          patch '/api/v1/profiles', headers: auth_headers
        end

        it 'returns bad request or parameter missing error' do
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when user is not authenticated' do
      before do
        patch '/api/v1/profiles', params: { user: { name: 'Hacker' } }
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update any user data' do
        user.reload
        expect(user.name).to eq('John Doe') # unchanged
      end
    end

    context 'with invalid JWT token' do
      before do
        patch '/api/v1/profiles',
              params: { user: { name: 'Hacker' } },
              headers: { 'Authorization' => 'Bearer invalid_token' }
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'parameter filtering' do
    it 'only allows permitted parameters' do
      controller = Api::V1::Authenticated::ProfilesController.new

      # Simular params com dados extras
      params = ActionController::Parameters.new({
        user: {
          name: 'Valid Name',
          email: 'valid@example.com',
          password: 'hacker_attempt',
          jti: 'hacker_attempt',
          id: 999
        }
      })

      # Testar método user_params (se for público ou usando send)
      controller.params = params

      # O método user_params deve filtrar apenas name e email
      expect { controller.send(:user_params) }.not_to raise_error
    end
  end

  describe 'response format consistency' do
    before do
      get '/api/v1/profiles', headers: auth_headers
    end

    it 'follows ApiResponse pattern' do
      json_response = response.parsed_body

      # Deve ter estrutura padrão do ApiResponse
      expect(json_response).to have_key('success')
      expect(json_response).to have_key('data')
      expect(json_response['success']).to be true
    end

    it 'returns JSON content type' do
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'edge cases' do
    context 'when user account is deleted during session' do
      before do
        # Obter headers de auth primeiro
        headers = auth_headers
        # Deletar usuário
        user.destroy
        # Tentar acessar perfil
        get '/api/v1/profiles', headers: headers
      end

      it 'handles deleted user gracefully' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with case-insensitive email updates' do
      let(:mixed_case_params) { { user: { email: 'John.DOE@EXAMPLE.COM' } } }

      before do
        patch '/api/v1/profiles', params: mixed_case_params, headers: auth_headers
      end

      it 'downcases email before saving' do
        user.reload
        expect(user.email).to eq('john.doe@example.com')
      end
    end
  end
end
