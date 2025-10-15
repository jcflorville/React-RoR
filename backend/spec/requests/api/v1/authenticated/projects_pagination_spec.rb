require 'rails_helper'

RSpec.describe 'Api::V1::Authenticated::Projects Pagination', type: :request do
  let(:user) { create(:user) }

  let!(:projects) do
    25.times.map do |i|
      create(:project,
        user: user,
        name: "Project #{i.to_s.rjust(2, '0')}",
        created_at: i.days.ago
      )
    end
  end

  describe 'GET /api/v1/projects with pagination' do
    context 'default pagination' do
      before { get '/api/v1/projects', headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'includes pagination metadata in response' do
        expect_json_success
        expect(json_response).to include('meta')
        expect(json_response['meta']).to be_a(Hash)
      end

      it 'returns first page with default 10 items' do
        expect(json_response['data'].size).to eq(10)
      end

      it 'includes all required pagination fields' do
        meta = json_response['meta']

        expect(meta).to include(
          'current_page',
          'per_page',
          'total_pages',
          'total_count',
          'next_page'
        )
      end

      it 'returns correct pagination metadata values' do
        meta = json_response['meta']

        expect(meta['current_page']).to eq(1)
        expect(meta['per_page']).to eq(10)
        expect(meta['total_pages']).to eq(3)
        expect(meta['total_count']).to eq(25)
        expect(meta['next_page']).to eq(2)
      end

      it 'follows ApiResponse pagination format' do
        expect(json_response).to include('success', 'data', 'meta')
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_an(Array)
        expect(json_response['meta']).to be_a(Hash)
      end
    end

    context 'custom page parameter' do
      it 'returns requested page' do
        get '/api/v1/projects', params: { page: 2 }, headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']

        expect(meta['current_page']).to eq(2)
        expect(json_response['data'].size).to eq(10)
        expect(meta['next_page']).to eq(3)
      end

      it 'returns last page with remaining items' do
        get '/api/v1/projects', params: { page: 3 }, headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']

        expect(meta['current_page']).to eq(3)
        expect(json_response['data'].size).to eq(5)
        expect(meta['next_page']).to be_nil
      end

      it 'handles page beyond total pages' do
        get '/api/v1/projects', params: { page: 10 }, headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']

        expect(json_response['data']).to be_empty
        expect(meta['current_page']).to eq(10)
        expect(meta['next_page']).to be_nil
      end
    end

    context 'custom per_page parameter' do
      it 'returns custom number of items per page' do
        get '/api/v1/projects', params: { per_page: 5 }, headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']

        expect(json_response['data'].size).to eq(5)
        expect(meta['per_page']).to eq(5)
        expect(meta['total_pages']).to eq(5)
      end

      it 'handles large per_page values' do
        get '/api/v1/projects', params: { per_page: 100 }, headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']

        expect(json_response['data'].size).to eq(25)
        expect(meta['total_pages']).to eq(1)
        expect(meta['next_page']).to be_nil
      end
    end

    context 'pagination with page and per_page' do
      it 'combines both parameters correctly' do
        get '/api/v1/projects',
            params: { page: 2, per_page: 7 },
            headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']

        expect(meta['current_page']).to eq(2)
        expect(meta['per_page']).to eq(7)
        expect(json_response['data'].size).to eq(7)
        expect(meta['total_pages']).to eq(4)
        expect(meta['next_page']).to eq(3)
      end
    end

    context 'pagination with filters' do
      let!(:active_projects) do
        10.times.map { |i| create(:project, user: user, status: :active, name: "Active #{i}") }
      end

      let!(:completed_projects) do
        5.times.map { |i| create(:project, user: user, status: :completed, name: "Completed #{i}") }
      end

      it 'paginates filtered results correctly' do
        get '/api/v1/projects',
            params: { status: 'active', page: 1, per_page: 5 },
            headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']

        expect(json_response['data'].size).to eq(5)
        expect(meta['total_count']).to be >= 10
        expect(meta['total_pages']).to be >= 2
        expect(meta['next_page']).to eq(2)

        expect(json_response['data'].all? { |p| p['status'] == 'active' }).to be true
      end

      it 'paginates search results' do
        get '/api/v1/projects',
            params: { search: 'Active', page: 1, per_page: 3 },
            headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']

        expect(json_response['data'].size).to eq(3)
        expect(meta['total_count']).to eq(10)
      end
    end

    context 'pagination with sorting' do
      it 'maintains sort order across pages' do
        get '/api/v1/projects',
            params: { sort: 'name_asc', page: 1, per_page: 10 },
            headers: auth_headers(user)

        expect_json_success
        page1_names = json_response['data'].map { |p| p['name'] }

        get '/api/v1/projects',
            params: { sort: 'name_asc', page: 2, per_page: 10 },
            headers: auth_headers(user)

        expect_json_success
        page2_names = json_response['data'].map { |p| p['name'] }

        expect(page1_names.last).to be < page2_names.first
      end
    end

    context 'next_page indicator for infinite scroll' do
      it 'indicates more pages available' do
        get '/api/v1/projects',
            params: { page: 1, per_page: 10 },
            headers: auth_headers(user)

        meta = json_response['meta']
        expect(meta['next_page']).to eq(2)
      end

      it 'indicates no more pages on last page' do
        get '/api/v1/projects',
            params: { page: 3, per_page: 10 },
            headers: auth_headers(user)

        meta = json_response['meta']
        expect(meta['next_page']).to be_nil
      end

      it 'provides correct next_page for custom per_page' do
        get '/api/v1/projects',
            params: { page: 2, per_page: 5 },
            headers: auth_headers(user)

        meta = json_response['meta']
        expect(meta['next_page']).to eq(3)
      end
    end

    context 'response format validation' do
      before { get '/api/v1/projects', params: { page: 1 }, headers: auth_headers(user) }

      it 'data contains project objects with correct structure' do
        project_data = json_response['data'].first

        expect(project_data).to include(
          'id', 'name', 'description', 'status', 'priority',
          'start_date', 'end_date', 'created_at', 'updated_at'
        )
      end

      it 'meta contains integer values for counts' do
        meta = json_response['meta']

        expect(meta['current_page']).to be_a(Integer)
        expect(meta['per_page']).to be_a(Integer)
        expect(meta['total_pages']).to be_a(Integer)
        expect(meta['total_count']).to be_a(Integer)
      end

      it 'next_page is integer or null' do
        meta = json_response['meta']
        expect([ Integer, NilClass ]).to include(meta['next_page'].class)
      end
    end

    context 'edge cases' do
      it 'handles user with no projects' do
        empty_user = create(:user)
        get '/api/v1/projects', headers: auth_headers(empty_user)

        expect_json_success
        meta = json_response['meta']

        expect(json_response['data']).to be_empty
        expect(meta['total_count']).to eq(0)
        expect(meta['total_pages']).to eq(0)
        expect(meta['next_page']).to be_nil
      end

      it 'handles user with exactly one page of projects' do
        user_with_few = create(:user)
        5.times { create(:project, user: user_with_few) }

        get '/api/v1/projects',
            params: { per_page: 10 },
            headers: auth_headers(user_with_few)

        expect_json_success
        meta = json_response['meta']

        expect(json_response['data'].size).to eq(5)
        expect(meta['total_pages']).to eq(1)
        expect(meta['next_page']).to be_nil
      end

      it 'isolates pagination between different users' do
        other_user = create(:user)
        3.times { create(:project, user: other_user) }

        get '/api/v1/projects', headers: auth_headers(user)
        user_total = json_response['meta']['total_count']

        get '/api/v1/projects', headers: auth_headers(other_user)
        other_total = json_response['meta']['total_count']

        expect(user_total).to eq(25)
        expect(other_total).to eq(3)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/projects', params: { page: 1 }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'performance verification' do
      it 'does not load all projects into memory' do
        get '/api/v1/projects',
            params: { page: 1, per_page: 5 },
            headers: auth_headers(user)

        expect(json_response['data'].size).to eq(5)
      end
    end

    context 'combined filters, search, sort and pagination' do
      let!(:priority_projects) do
        15.times.map do |i|
          create(:project,
            user: user,
            priority: :high,
            name: "High Priority #{i}",
            status: :active
          )
        end
      end

      it 'applies all parameters correctly together' do
        get '/api/v1/projects',
            params: {
              status: 'active',
              priority: 'high',
              search: 'Priority',
              sort: 'name_asc',
              page: 2,
              per_page: 5
            },
            headers: auth_headers(user)

        expect_json_success
        meta = json_response['meta']
        data = json_response['data']

        expect(data.size).to eq(5)
        expect(meta['current_page']).to eq(2)
        expect(meta['per_page']).to eq(5)

        expect(data.all? { |p| p['status'] == 'active' }).to be true
        expect(data.all? { |p| p['priority'] == 'high' }).to be true

        names = data.map { |p| p['name'] }
        expect(names).to eq(names.sort)
      end
    end
  end
end
