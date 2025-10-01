# spec/services/projects/creator_spec.rb
require 'rails_helper'

RSpec.describe Projects::Creator, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:category1) { create(:category) }
    let(:category2) { create(:category) }

    let(:valid_params) do
      {
        name: 'Test Project',
        description: 'Test Description',
        priority: 'high',
        start_date: Date.current,
        end_date: 1.month.from_now
      }
    end

    context 'with valid parameters' do
      it 'creates project successfully' do
        result = described_class.call(user: user, params: valid_params)

        expect(result.success?).to be true
        expect(result.data).to be_a(Project)
        expect(result.data.name).to eq('Test Project')
        expect(result.data.user).to eq(user)
        expect(result.message).to eq('Project created successfully')
      end

      it 'creates project with correct attributes' do
        result = described_class.call(user: user, params: valid_params)
        project = result.data

        expect(project.name).to eq('Test Project')
        expect(project.description).to eq('Test Description')
        expect(project.priority).to eq('high')
        expect(project.status).to eq('draft')
        expect(project.start_date).to eq(Date.current) # set by model default
        expect(project.end_date).to be_nil # not processed by Command Object
      end

      it 'associates categories when provided' do
        params_with_categories = valid_params.merge(category_ids: [ category1.id, category2.id ])
        result = described_class.call(user: user, params: params_with_categories)

        expect(result.success?).to be true
        expect(result.data.categories).to include(category1, category2)
      end

      it 'sets default values for optional fields' do
        minimal_params = { name: 'Minimal Project' }
        result = described_class.call(user: user, params: minimal_params)

        expect(result.success?).to be true
        expect(result.data.status).to eq('draft')
        expect(result.data.priority).to eq('medium')
        expect(result.data.start_date).to eq(Date.current)
      end
    end

    context 'with invalid parameters' do
      it 'fails when name is missing' do
        invalid_params = valid_params.except(:name)
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to create project')
        expect(result.errors[:name]).to be_present
      end

      it 'fails when name is too short' do
        invalid_params = valid_params.merge(name: 'x')
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.errors[:name]).to be_present
      end

      # Note: end_date validation happens at model level, not Command Object level
      # Command Object only processes :name, :description, :status, :priority

      it 'ignores non-existent categories' do
        invalid_params = valid_params.merge(category_ids: [ 99999 ])
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be true
        expect(result.data.categories).to be_empty # no categories found with id 99999
      end
    end

    context 'edge cases' do
      it 'handles empty category_ids' do
        params_with_empty_categories = valid_params.merge(category_ids: [])
        result = described_class.call(user: user, params: params_with_empty_categories)

        expect(result.success?).to be true
        expect(result.data.categories).to be_empty
      end

      it 'only processes allowed parameters' do
        params_with_extra = valid_params.merge(
          start_date: 1.week.from_now,
          end_date: 1.month.from_now,
          extra_field: 'ignored'
        )
        result = described_class.call(user: user, params: params_with_extra)

        expect(result.success?).to be true
        # Command Object ignores start_date, end_date, extra_field
        expect(result.data.start_date).to eq(Date.current) # model default
        expect(result.data.end_date).to be_nil # not processed
      end

      it 'associates only existing categories' do
        params_mixed_categories = valid_params.merge(
          category_ids: [ category1.id, 99999, category2.id ]
        )
        result = described_class.call(user: user, params: params_mixed_categories)

        expect(result.success?).to be true
        expect(result.data.categories).to include(category1, category2)
        expect(result.data.categories.count).to eq(2)
      end
    end
  end
end
