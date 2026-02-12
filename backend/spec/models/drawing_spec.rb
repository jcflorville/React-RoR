require 'rails_helper'

RSpec.describe Drawing, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:canvas_data) }
    it { should validate_presence_of(:lock_version) }
  end

  describe 'factory' do
    it 'creates a valid drawing' do
      drawing = build(:drawing)
      expect(drawing).to be_valid
    end

    it 'has default canvas_data structure' do
      drawing = create(:drawing)
      expect(drawing.canvas_data).to include('version', 'objects', 'background')
      expect(drawing.canvas_data['objects']).to be_an(Array)
    end
  end
end
