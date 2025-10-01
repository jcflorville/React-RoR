# spec/support/jwt_helpers.rb
module JwtHelpers
  def generate_jwt_token(user)
    # Usar a estratégia JWT do Devise para gerar o token corretamente
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, user)
    auth_headers['Authorization']
  end

  def jwt_secret_key
    ENV['DEVISE_JWT_SECRET_KEY'] || Rails.application.credentials.devise_jwt_secret_key || 'test_secret_key'
  end

  def auth_headers(user)
    # Usar o helper do Devise JWT para gerar headers de autenticação
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    Devise::JWT::TestHelpers.auth_headers(headers, user)
  end

  def json_response
    JSON.parse(response.body)
  end

  def expect_json_success(message = nil)
    expect(json_response['success']).to be true
    expect(json_response['message']).to eq(message) if message
  end

  def expect_json_error(message = nil)
    expect(json_response['success']).to be false
    expect(json_response['message']).to eq(message) if message
  end
end

RSpec.configure do |config|
  config.include JwtHelpers, type: :request
end
