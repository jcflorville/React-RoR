require 'rails_helper'

RSpec.describe Drawings::Updater, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:drawing) { create(:drawing, user: user, title: 'Original Title') }

    context 'with valid parameters' do
      it 'updates drawing successfully' do
        params = { title: 'Updated Title' }
        result = described_class.call(drawing: drawing, params: params)

        expect(result.success?).to be true
        expect(result.data.title).to eq('Updated Title')
        expect(result.message).to eq('Drawing updated successfully')
      end

      it 'updates canvas_data' do
        new_canvas_data = {
          version: '5.3.0',
          objects: [ { type: 'path', points: [ [ 0, 0 ], [ 10, 10 ] ] } ],
          background: '#ffffff'
        }
        params = { canvas_data: new_canvas_data }

        result = described_class.call(drawing: drawing, params: params)

        expect(result.success?).to be true
        expect(result.data.canvas_data['objects']).to eq(new_canvas_data[:objects].map(&:stringify_keys))
      end

      it 'increments lock_version on successful update' do
        initial_version = drawing.lock_version
        params = { title: 'New Title' }

        result = described_class.call(drawing: drawing, params: params)

        expect(result.success?).to be true
        expect(result.data.lock_version).to eq(initial_version + 1)
      end

      it 'ignores empty params' do
        params = {}
        result = described_class.call(drawing: drawing, params: params)

        expect(result.success?).to be true
        expect(result.data.title).to eq('Original Title')
      end
    end

    context 'with optimistic locking' do
      it 'fails when lock_version mismatch' do
        params = { title: 'New Title', lock_version: 999 }
        result = described_class.call(drawing: drawing, params: params)

        expect(result.success?).to be false
        expect(result.message).to include('modified by another user')
      end

      it 'succeeds when lock_version matches' do
        params = { title: 'New Title', lock_version: drawing.lock_version }
        result = described_class.call(drawing: drawing, params: params)

        expect(result.success?).to be true
        expect(result.data.title).to eq('New Title')
      end
    end

    context 'with invalid parameters' do
      it 'fails when title is too long' do
        params = { title: 'a' * 300 }
        result = described_class.call(drawing: drawing, params: params)

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to update drawing')
        expect(result.errors).to be_present
      end
    end
  end
end
