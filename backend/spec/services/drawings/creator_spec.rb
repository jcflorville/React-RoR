require 'rails_helper'

RSpec.describe Drawings::Creator, type: :service do
  describe '.call' do
    let(:user) { create(:user) }

    context 'with valid parameters' do
      let(:params) { { title: 'My Drawing' } }

      it 'creates drawing successfully' do
        result = described_class.call(user: user, params: params)

        expect(result.success?).to be true
        expect(result.data).to be_a(Drawing)
        expect(result.data.title).to eq('My Drawing')
        expect(result.data.user).to eq(user)
        expect(result.message).to eq('Drawing created successfully')
      end

      it 'sets default canvas_data' do
        result = described_class.call(user: user, params: {})

        expect(result.success?).to be true
        expect(result.data.canvas_data).to include(
          'version' => '5.3.0',
          'objects' => [],
          'background' => '#ffffff'
        )
      end

      it 'uses provided canvas_data' do
        custom_data = { version: '5.3.0', objects: [ { 'type' => 'circle' } ], background: '#000000' }
        params_with_canvas = { title: 'Custom', canvas_data: custom_data }

        result = described_class.call(user: user, params: params_with_canvas)

        expect(result.success?).to be true
        expect(result.data.canvas_data).to eq(custom_data.stringify_keys)
      end

      it 'sets default title when not provided' do
        result = described_class.call(user: user, params: {})

        expect(result.success?).to be true
        expect(result.data.title).to eq('Untitled')
      end

      it 'initializes lock_version to 0' do
        result = described_class.call(user: user, params: {})

        expect(result.success?).to be true
        expect(result.data.lock_version).to eq(0)
      end
    end

    context 'with invalid parameters' do
      it 'fails when title is too long' do
        params = { title: 'a' * 300 }
        result = described_class.call(user: user, params: params)

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to create drawing')
        expect(result.errors).to be_present
      end
    end
  end
end
