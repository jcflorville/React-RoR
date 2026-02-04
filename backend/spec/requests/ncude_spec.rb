require "rails_helper"

RSpec.describe "/api/v1/contacts" do
  describe 'GET index' do
    it "responds OK with empty records list" do
      get "/api/v1/contacts"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "data" => [] })
    end

    it "responds OK with some records" do
      contact = Contact.create(first_name: 'John', last_name: 'Doe', email: 'john.doe@example.com')

      get "/api/v1/contacts"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        {
          'data' => [
            {
              'id' => contact.id,
              'first_name' => 'John',
              'last_name' => 'Doe',
              'email' => 'john.doe@example.com'
            }
          ]
        }
      )
    end

    it "responds with some record as search result" do
      Contact.create(first_name: 'Foo', last_name: 'Bar', email: 'foo.bar@example.com')
      contact = Contact.create(first_name: 'John', last_name: 'Doe', email: 'john.doe@example.com')

      get "/api/v1/contacts", params: { search: 'doe' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        {
          'data' => [
            {
              'id' => contact.id,
              'first_name' => 'John',
              'last_name' => 'Doe',
              'email' => 'john.doe@example.com'
            }
          ]
        }
      )
    end
  end

  describe 'POST index' do
    it 'creates new contact' do
      post "/api/v1/contacts", params: { 'contact' => { 'email' => 'tester@example.com', 'first_name' => 'Tester' } }

      created_contact = Contact.last

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        {
          'data' =>
            {
            'id' => created_contact.id,
            'first_name' => 'Tester',
            'last_name' => nil,
            'email' => 'tester@example.com'
          }
        }
      )
    end

    it 'validates first_name and email' do
      post "/api/v1/contacts", params: { 'contact' => { 'last_name' => 'Tester' } }

      created_contact = Contact.last
      expect(created_contact).to eq nil

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to eq(
        { "errors" => { "email" => [ "can't be blank" ], "first_name" => [ "can't be blank" ] } }
      )
    end
  end
end
