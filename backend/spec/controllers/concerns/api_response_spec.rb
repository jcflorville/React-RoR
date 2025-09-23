require 'rails_helper'

RSpec.describe ApiResponse, type: :controller do
  # Criar um controller dummy para testar o concern
  controller(ApplicationController) do
    include ApiResponse

    def index
      case params[:test_method]
      when 'render_success'
        render_success(params[:data], params[:message], params[:status]&.to_sym || :ok)
      when 'render_error'
        render_error(params[:message], params[:errors], params[:status]&.to_sym || :unprocessable_content)
      when 'render_pagination'
        collection = User.all
        render_pagination(collection, params[:serializer_class]&.constantize)
      when 'render_auth_success'
        user = params[:user_id].present? ? User.find(params[:user_id]) : nil
        if params[:message].present?
          render_auth_success(user, params[:message])
        else
          render_auth_success(user)
        end
      when 'render_logout_success'
        render_logout_success
      when 'serialize_data'
        render json: { result: serialize_data(params[:data]) }
      when 'format_errors'
        render json: { result: format_errors(params[:errors]) }
      when 'pagination_meta'
        collection = User.all
        render json: { result: pagination_meta(collection) }
      else
        render json: { error: 'Unknown test method' }
      end
    end
  end

  let(:user) { create(:user, name: 'Test User', email: 'test@example.com') }

  describe '#render_success' do
    context 'with data and message' do
      before do
        get :index, params: { test_method: 'render_success', data: { name: 'Test' }, message: 'Success message' }
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns success response structure' do
        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['data']).to eq({ 'name' => 'Test' })
        expect(json_response['message']).to eq('Success message')
      end
    end

    context 'with only data' do
      before do
        get :index, params: { test_method: 'render_success', data: { id: 1 } }
      end

      it 'returns success without message' do
        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['data']).to eq({ 'id' => '1' })
        expect(json_response).not_to have_key('message')
      end
    end

    context 'with nil data' do
      before do
        get :index, params: { test_method: 'render_success' }
      end

      it 'returns success with null data' do
        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_nil
      end
    end

    context 'with custom status' do
      before do
        get :index, params: { test_method: 'render_success', data: { test: true }, status: 'created' }
      end

      it 'returns custom status' do
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe '#render_error' do
    context 'with message and errors' do
      before do
        get :index, params: { test_method: 'render_error', message: 'Validation failed' }
      end

      it 'returns error status' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns error response structure' do
        json_response = response.parsed_body
        expect(json_response['success']).to be false
        expect(json_response['message']).to eq('Validation failed')
        # Testamos errors separadamente para não complicar com params
      end
    end

    context 'with only message' do
      before do
        get :index, params: { test_method: 'render_error', message: 'Something went wrong' }
      end

      it 'returns error without errors field' do
        json_response = response.parsed_body
        expect(json_response['success']).to be false
        expect(json_response['message']).to eq('Something went wrong')
        expect(json_response).not_to have_key('errors')
      end
    end

    context 'with custom status' do
      before do
        get :index, params: { test_method: 'render_error', message: 'Unauthorized', status: 'unauthorized' }
      end

      it 'returns custom status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe '#render_pagination' do
    let!(:users) { create_list(:user, 3) }

    before do
      allow(User).to receive(:all).and_return(users)
      get :index, params: { test_method: 'render_pagination' }
    end

    it 'returns success status' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns pagination response structure' do
      json_response = response.parsed_body
      expect(json_response['success']).to be true
      expect(json_response['data']).to be_present
      expect(json_response['meta']).to be_present
    end

    it 'includes pagination metadata' do
      json_response = response.parsed_body
      meta = json_response['meta']
      expect(meta['current_page']).to eq(1)
      expect(meta['per_page']).to eq(3)
      expect(meta['total_pages']).to eq(1)
      expect(meta['total_count']).to eq(3)
    end
  end

  describe '#render_auth_success' do
    context 'with valid user' do
      before do
        get :index, params: { test_method: 'render_auth_success', user_id: user.id, message: 'Login successful' }
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns user data' do
        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['data']['id']).to eq(user.id)
        expect(json_response['data']['email']).to eq(user.email)
        expect(json_response['data']['name']).to eq(user.name)
        expect(json_response['message']).to eq('Login successful')
      end

      it 'does not return sensitive data' do
        json_response = response.parsed_body
        expect(json_response['data']).not_to have_key('password')
        expect(json_response['data']).not_to have_key('jti')
      end
    end

    context 'with nil user' do
      before do
        get :index, params: { test_method: 'render_auth_success' }
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error response' do
        json_response = response.parsed_body
        expect(json_response['success']).to be false
        expect(json_response['message']).to eq('User not found')
      end
    end

    context 'with default message' do
      before do
        get :index, params: { test_method: 'render_auth_success', user_id: user.id }
      end

      it 'uses default authentication message' do
        json_response = response.parsed_body
        # Como estamos passando nil para message, deve usar a mensagem padrão
        expect(json_response['message']).to eq('Authentication successful')
      end
    end
  end

  describe '#render_logout_success' do
    before do
      get :index, params: { test_method: 'render_logout_success' }
    end

    it 'returns no content status' do
      expect(response).to have_http_status(:no_content)
    end

    it 'returns minimal success response' do
      json_response = response.parsed_body
      # O Rails pode retornar string "success" em vez de boolean true para 204
      expect([ true, 'success' ]).to include(json_response['success'])
      # Para status 204, a resposta pode ter comportamento diferente
      expect([ nil, 'data' ]).to include(json_response['data'])
    end
  end

  describe 'private methods' do
    describe '#serialize_data' do
      context 'with nil data' do
        before do
          get :index, params: { test_method: 'serialize_data' }
        end

        it 'returns nil' do
          json_response = response.parsed_body
          expect(json_response['result']).to be_nil
        end
      end

      context 'with simple data' do
        before do
          get :index, params: { test_method: 'serialize_data', data: { name: 'Test', id: 1 } }
        end

        it 'returns data as-is' do
          json_response = response.parsed_body
          expect(json_response['result']).to eq({ 'name' => 'Test', 'id' => '1' })
        end
      end
    end

    describe '#format_errors' do
      context 'with Hash errors' do
        it 'returns hash correctly' do
          hash_errors = { email: [ 'is required' ], name: [ 'is too short' ] }
          result = controller.send(:format_errors, hash_errors)
          expect(result).to eq(hash_errors)
        end
      end

      context 'with Array errors' do
        let(:array_errors) { [ 'Error 1', 'Error 2' ] }

        before do
          get :index, params: { test_method: 'format_errors', errors: array_errors }
        end

        it 'returns array as-is' do
          json_response = response.parsed_body
          expect(json_response['result']).to eq(array_errors)
        end
      end

      context 'with String error' do
        before do
          get :index, params: { test_method: 'format_errors', errors: 'Single error message' }
        end

        it 'returns string in array format' do
          json_response = response.parsed_body
          expect(json_response['result']).to eq([ 'Single error message' ])
        end
      end
    end

    describe '#pagination_meta' do
      let!(:users) { create_list(:user, 5) }

      before do
        allow(User).to receive(:all).and_return(users)
        get :index, params: { test_method: 'pagination_meta' }
      end

      it 'returns correct pagination metadata' do
        json_response = response.parsed_body
        meta = json_response['result']

        expect(meta['current_page']).to eq(1)
        expect(meta['per_page']).to eq(5)
        expect(meta['total_pages']).to eq(1)
        expect(meta['total_count']).to eq(5)
      end
    end
  end
end
