# spec/services/projects/finder_spec.rb
require 'rails_helper'

RSpec.describe Projects::Finder, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:category) { create(:category) }

    let!(:user_project1) { create(:project, user: user, name: 'User Project 1', status: :active) }
    let!(:user_project2) { create(:project, user: user, name: 'User Project 2', status: :completed) }
    let!(:other_project) { create(:project, user: other_user, name: 'Other Project') }

    before do
      user_project1.categories << category
    end

    context 'finding all user projects' do
      it 'returns only user projects' do
        result = described_class.call(user: user, params: {})

        expect(result.success?).to be true
        expect(result.data).to include(user_project1, user_project2)
        expect(result.data).not_to include(other_project)
      end
    end

    context 'finding specific project by id' do
      it 'returns the project when it belongs to user' do
        result = described_class.call(user: user, params: { id: user_project1.id })

        expect(result.success?).to be true
        expect(result.data).to eq(user_project1)
      end

      it 'includes associated data for single project' do
        create(:task, project: user_project1)
        result = described_class.call(user: user, params: { id: user_project1.id })

        expect(result.success?).to be true
        expect(result.data.association(:tasks)).to be_loaded
        expect(result.data.association(:categories)).to be_loaded
      end

      it 'fails when project does not belong to user' do
        result = described_class.call(user: user, params: { id: other_project.id })

        expect(result.success?).to be false
        expect(result.message).to eq('Project not found')
      end

      it 'fails when project does not exist' do
        result = described_class.call(user: user, params: { id: 99999 })

        expect(result.success?).to be false
        expect(result.message).to eq('Project not found')
      end
    end

    context 'filtering projects' do
      it 'filters by status' do
        result = described_class.call(user: user, params: { status: 'active' })

        expect(result.success?).to be true
        expect(result.data).to include(user_project1)
        expect(result.data).not_to include(user_project2)
      end

      it 'filters by priority' do
        high_priority_project = create(:project, user: user, priority: :high)
        result = described_class.call(user: user, params: { priority: 'high' })

        expect(result.success?).to be true
        expect(result.data).to include(high_priority_project)
        expect(result.data).not_to include(user_project1, user_project2)
      end
    end

    context 'searching projects' do
      it 'searches by name' do
        result = described_class.call(user: user, params: { search: 'Project 1' })

        expect(result.success?).to be true
        expect(result.data).to include(user_project1)
        expect(result.data).not_to include(user_project2)
      end

      it 'searches by description' do
        project_with_desc = create(:project, user: user, description: 'Special description')
        result = described_class.call(user: user, params: { search: 'Special' })

        expect(result.success?).to be true
        expect(result.data).to include(project_with_desc)
      end
    end

    context 'sorting projects' do
      it 'sorts by name ascending' do
        result = described_class.call(user: user, params: { sort: 'name_asc' })

        expect(result.success?).to be true
        expect(result.data.first.name).to eq('User Project 1')
      end

      it 'applies default ordering when no sort specified' do
        result = described_class.call(user: user, params: {})

        expect(result.success?).to be true
        expect(result.data.to_sql).to include('ORDER BY')
      end
    end
  end
end
