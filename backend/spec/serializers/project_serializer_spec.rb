require 'rails_helper'

RSpec.describe ProjectSerializer, type: :serializer do
  describe 'serialization' do
    let(:user) { create(:user) }
    let(:category1) { create(:category, name: 'Frontend') }
    let(:category2) { create(:category, name: 'Backend') }
    let(:project) do
      create(:project,
        user: user,
        name: 'Test Project',
        description: 'A test project',
        status: 'active',
        priority: 'high',
        categories: [ category1, category2 ]
      )
    end
    let!(:task1) { create(:task, project: project, title: 'Task 1', status: 'todo') }
    let!(:task2) { create(:task, project: project, title: 'Task 2', status: 'in_progress') }

    subject(:serialized_data) { described_class.new(project).serializable_hash }

    context 'basic attributes' do
      it 'includes all basic project attributes' do
        attributes = serialized_data.dig(:data, :attributes)

        expect(attributes).to include(
          id: project.id,
          name: 'Test Project',
          description: 'A test project',
          status: 'active',
          priority: 'high'
        )
      end

      it 'includes computed attributes' do
        attributes = serialized_data.dig(:data, :attributes)

        expect(attributes).to include(
          :progress_percentage,
          :overdue,
          :status_humanized,
          :priority_humanized
        )
      end

      it 'includes timestamps' do
        attributes = serialized_data.dig(:data, :attributes)

        expect(attributes).to include(
          :created_at,
          :updated_at
        )
      end
    end

    context 'relationships' do
      it 'includes tasks relationship' do
        relationships = serialized_data.dig(:data, :relationships)

        expect(relationships).to have_key(:tasks)
        expect(relationships[:tasks]).to have_key(:data)
      end

      it 'includes correct number of tasks' do
        relationships = serialized_data.dig(:data, :relationships)
        tasks_data = relationships.dig(:tasks, :data)

        expect(tasks_data).to be_an(Array)
        expect(tasks_data.size).to eq(2)
      end

      it 'includes task ids in relationship' do
        relationships = serialized_data.dig(:data, :relationships)
        tasks_data = relationships.dig(:tasks, :data)
        task_ids = tasks_data.map { |task| task[:id] }

        expect(task_ids).to match_array([ task1.id.to_s, task2.id.to_s ])
      end

      it 'includes categories relationship' do
        relationships = serialized_data.dig(:data, :relationships)

        expect(relationships).to have_key(:categories)
        expect(relationships[:categories]).to have_key(:data)
      end

      it 'includes correct number of categories' do
        relationships = serialized_data.dig(:data, :relationships)
        categories_data = relationships.dig(:categories, :data)

        expect(categories_data).to be_an(Array)
        expect(categories_data.size).to eq(2)
      end

      it 'includes category ids in relationship' do
        relationships = serialized_data.dig(:data, :relationships)
        categories_data = relationships.dig(:categories, :data)
        category_ids = categories_data.map { |category| category[:id] }

        expect(category_ids).to match_array([ category1.id.to_s, category2.id.to_s ])
      end
    end

    context 'included data' do
      subject(:serialized_data) do
        described_class.new(project, include: [ :tasks, :categories ]).serializable_hash
      end

      it 'includes tasks data when requested' do
        included_data = serialized_data[:included]

        task_included = included_data.select { |item| item[:type] == :task }

        expect(task_included.size).to eq(2)
        expect(task_included.map { |t| t.dig(:attributes, :title) }).to match_array([ 'Task 1', 'Task 2' ])
      end

      it 'includes categories data when requested' do
        included_data = serialized_data[:included]
        category_included = included_data.select { |item| item[:type] == :category }

        expect(category_included.size).to eq(2)
        expect(category_included.map { |c| c.dig(:attributes, :name) }).to match_array([ 'Frontend', 'Backend' ])
      end
    end

    context 'computed attributes values' do
      it 'returns correct status_humanized' do
        attributes = serialized_data.dig(:data, :attributes)
        expect(attributes[:status_humanized]).to eq('Active')
      end

      it 'returns correct priority_humanized' do
        attributes = serialized_data.dig(:data, :attributes)
        expect(attributes[:priority_humanized]).to eq('High')
      end

      it 'returns boolean for overdue attribute' do
        attributes = serialized_data.dig(:data, :attributes)
        expect(attributes[:overdue]).to be_in([ true, false ])
      end

      it 'returns numeric value for progress_percentage' do
        attributes = serialized_data.dig(:data, :attributes)
        expect(attributes[:progress_percentage]).to be_a(Numeric)
        expect(attributes[:progress_percentage]).to be >= 0
        expect(attributes[:progress_percentage]).to be <= 100
      end
    end
  end

  describe 'serialization without associations loaded' do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user) }

    context 'when project is loaded without includes' do
      subject(:serialized_data) { described_class.new(project).serializable_hash }

      it 'still includes relationship keys even if associations are not loaded' do
        relationships = serialized_data.dig(:data, :relationships)

        expect(relationships).to have_key(:tasks)
        expect(relationships).to have_key(:categories)
      end
    end
  end
end
