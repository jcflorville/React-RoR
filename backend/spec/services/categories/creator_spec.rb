# spec/services/categories/creator_spec.rb
require 'rails_helper'

RSpec.describe Categories::Creator, type: :service do
  describe '.call' do
    let(:user) { create(:user) }

    let(:valid_params) do
      {
        name: 'Test Category',
        description: 'Test Description',
        color: '#FF0000'
      }
    end

    context 'with valid parameters' do
      it 'creates category successfully' do
        result = described_class.call(params: valid_params)

        expect(result.success?).to be true
        expect(result.data).to be_a(Category)
        expect(result.data.name).to eq('Test Category')
        expect(result.data.description).to eq('Test Description')
        expect(result.data.color).to eq('#FF0000')
        expect(result.message).to eq('Category created successfully')
      end

      it 'creates category with minimal params' do
        minimal_params = { name: 'Minimal Category' }
        result = described_class.call(params: minimal_params)

        expect(result.success?).to be true
        expect(result.data.name).to eq('Minimal Category')
        expect(result.data.description).to be_nil
        expect(result.data.color).to eq('#6B7280') # default color from model
      end
    end

    context 'with invalid parameters' do
      it 'fails when name is missing' do
        invalid_params = valid_params.except(:name)
        result = described_class.call(params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to create category')
        expect(result.errors[:name]).to be_present
      end

      it 'fails when name is too short' do
        invalid_params = valid_params.merge(name: 'x')
        result = described_class.call(params: invalid_params)

        expect(result.success?).to be false
        expect(result.errors[:name]).to be_present
      end

      it 'fails when name already exists' do
        create(:category, name: 'Test Category')
        result = described_class.call(params: valid_params)

        expect(result.success?).to be false
        expect(result.errors[:name]).to be_present
      end

      it 'fails with invalid color format' do
        invalid_params = valid_params.merge(color: 'invalid-color')
        result = described_class.call(params: invalid_params)

        expect(result.success?).to be false
        expect(result.errors[:color]).to be_present
      end

      it 'fails when name is too long' do
        long_name = 'a' * 51 # exceeds 50 character limit
        invalid_params = valid_params.merge(name: long_name)
        result = described_class.call(params: invalid_params)

        expect(result.success?).to be false
        expect(result.errors[:name]).to be_present
      end

      it 'fails when description is too long' do
        long_description = 'a' * 501 # exceeds 500 character limit
        invalid_params = valid_params.merge(description: long_description)
        result = described_class.call(params: invalid_params)

        expect(result.success?).to be false
        expect(result.errors[:description]).to be_present
      end
    end

    context 'edge cases' do
      it 'accepts valid hex colors' do
        valid_colors = [ '#FF0000', '#00FF00', '#0000FF', '#FFF', '#000' ]

        valid_colors.each do |color|
          params = valid_params.merge(name: "Category #{color}", color: color)
          result = described_class.call(params: params)

          expect(result.success?).to be true
          expect(result.data.color).to eq(color)
        end
      end

      it 'handles empty description' do
        params_without_description = valid_params.except(:description)
        result = described_class.call(params: params_without_description)

        expect(result.success?).to be true
        expect(result.data.description).to be_nil
      end

      it 'ignores extra parameters' do
        params_with_extra = valid_params.merge(
          extra_field: 'ignored',
          user_id: 123,
          projects: 'ignored'
        )
        result = described_class.call(params: params_with_extra)

        expect(result.success?).to be true
        expect(result.data.name).to eq('Test Category')
        # extra fields are ignored by .slice()
      end
    end
  end
end
