require 'rails_helper'

RSpec.describe 'CommentBlueprint Serialization', type: :request do
  let(:user) { create(:user, name: 'Commenter') }
  let(:project) { create(:project, user: user) }
  let(:task) { create(:task, project: project, user: user) }
  let!(:comment) do
    create(:comment,
      task: task,
      user: user,
      content: 'This is a test comment'
    )
  end

  describe 'GET /api/v1/comments - CommentBlueprint index' do
    before { get '/api/v1/comments', headers: auth_headers(user) }

    context 'response structure' do
      it 'returns success response format' do
        expect(response).to have_http_status(:success)
        expect_json_success
        expect(json_response['data']).to be_an(Array)
      end

      it 'includes comment basic attributes' do
        comment_data = json_response['data'].first

        expect(comment_data).to include(
          'id' => comment.id,
          'content' => 'This is a test comment'
        )
      end

      it 'includes computed attributes' do
        comment_data = json_response['data'].first

        expect(comment_data).to have_key('edited')
        expect(comment_data).to have_key('author_name')
        expect(comment_data['edited']).to be_in([ true, false ])
        expect(comment_data['author_name']).to eq('Commenter')
      end

      it 'includes timestamps' do
        comment_data = json_response['data'].first

        expect(comment_data).to include(
          'created_at',
          'updated_at'
        )
      end

      it 'includes edited_at when applicable' do
        comment_data = json_response['data'].first
        expect(comment_data).to have_key('edited_at')
      end
    end

    context 'data types' do
      it 'returns correct data types for each field' do
        comment_data = json_response['data'].first

        expect(comment_data['id']).to be_an(Integer)
        expect(comment_data['content']).to be_a(String)
        expect(comment_data['edited']).to be_in([ true, false ])
        expect(comment_data['author_name']).to be_a(String)
        expect(comment_data['created_at']).to be_a(String)
        expect(comment_data['updated_at']).to be_a(String)
      end
    end
  end

  describe 'POST /api/v1/comments - CommentBlueprint create' do
    let(:comment_params) do
      {
        comment: {
          content: 'New comment content',
          task_id: task.id
        }
      }
    end

    before { post '/api/v1/comments', params: comment_params.to_json, headers: auth_headers(user) }

    it 'returns created comment with CommentBlueprint' do
      expect(response).to have_http_status(:created)
      expect_json_success

      comment_data = json_response['data']
      expect(comment_data['content']).to eq('New comment content')
      expect(comment_data['author_name']).to eq('Commenter')
    end

    it 'marks new comment as not edited' do
      comment_data = json_response['data']

      expect(comment_data['edited']).to eq(false)
      expect(comment_data['edited_at']).to be_nil
    end
  end

  describe 'PATCH /api/v1/comments/:id - CommentBlueprint update' do
    let(:update_params) do
      {
        comment: {
          content: 'Updated comment content'
        }
      }
    end

    before do
      # Wait a moment to ensure updated_at differs from created_at
      sleep 0.1
      patch "/api/v1/comments/#{comment.id}", params: update_params.to_json, headers: auth_headers(user)
    end

    it 'returns updated comment with CommentBlueprint' do
      expect(response).to have_http_status(:success)
      expect_json_success

      comment_data = json_response['data']
      expect(comment_data['content']).to eq('Updated comment content')
    end

    it 'marks updated comment as edited' do
      comment_data = json_response['data']

      expect(comment_data['edited']).to eq(true)
      expect(comment_data['edited_at']).not_to be_nil
    end
  end

  describe 'computed fields accuracy' do
    context 'when comment has never been edited' do
      let!(:fresh_comment) do
        create(:comment,
          task: task,
          user: user,
          content: 'Fresh comment'
        )
      end

      before { get '/api/v1/comments', headers: auth_headers(user) }

      it 'correctly identifies as not edited' do
        fresh_comment_data = json_response['data'].find { |c| c['content'] == 'Fresh comment' }

        expect(fresh_comment_data['edited']).to eq(false)
        expect(fresh_comment_data['edited_at']).to be_nil
      end
    end

    context 'author_name field' do
      let!(:second_comment) do
        create(:comment,
          task: task,
          user: user,
          content: 'Another comment from same user'
        )
      end

      before { get '/api/v1/comments', headers: auth_headers(user) }

      it 'shows correct author name for each comment' do
        first_comment = json_response['data'].find { |c| c['content'] == 'This is a test comment' }
        second_comment_data = json_response['data'].find { |c| c['content'] == 'Another comment from same user' }

        expect(first_comment).to be_present
        expect(second_comment_data).to be_present

        expect(first_comment['author_name']).to eq('Commenter')
        expect(second_comment_data['author_name']).to eq('Commenter')
      end
    end
  end
end
