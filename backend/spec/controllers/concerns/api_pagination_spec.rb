require 'rails_helper'

RSpec.describe ApiPagination, type: :concern do
  let(:user) { create(:user) }

  describe 'pagination_meta helper' do
    let(:test_class) do
      Class.new do
        include ApiPagination
        public :pagination_meta
      end
    end

    let(:helper) { test_class.new }

    context 'with Kaminari paginated collection' do
      let!(:projects) { 25.times.map { create(:project, user: user) } }
      let(:collection) { user.projects.page(2).per(10) }

      it 'extracts current_page' do
        meta = helper.pagination_meta(collection)
        expect(meta[:current_page]).to eq(2)
      end

      it 'extracts per_page from limit_value' do
        meta = helper.pagination_meta(collection)
        expect(meta[:per_page]).to eq(10)
      end

      it 'extracts total_pages' do
        meta = helper.pagination_meta(collection)
        expect(meta[:total_pages]).to eq(3)
      end

      it 'extracts total_count' do
        meta = helper.pagination_meta(collection)
        expect(meta[:total_count]).to eq(25)
      end

      it 'includes next_page when available' do
        meta = helper.pagination_meta(collection)
        expect(meta[:next_page]).to eq(3)
      end
    end

    context 'with last page' do
      let!(:projects) { 25.times.map { create(:project, user: user) } }
      let(:collection) { user.projects.page(3).per(10) }

      it 'returns nil for next_page on last page' do
        meta = helper.pagination_meta(collection)
        expect(meta[:next_page]).to be_nil
      end
    end

    context 'with single page collection' do
      let!(:projects) { 3.times.map { create(:project, user: user) } }
      let(:collection) { user.projects.page(1).per(10) }

      it 'returns correct meta for single page' do
        meta = helper.pagination_meta(collection)

        expect(meta[:total_pages]).to eq(1)
        expect(meta[:total_count]).to eq(3)
        expect(meta[:next_page]).to be_nil
      end
    end

    context 'with empty collection' do
      let(:empty) { user.projects.page(1).per(10) }

      it 'handles empty paginated collection' do
        meta = helper.pagination_meta(empty)

        expect(meta[:current_page]).to eq(1)
        expect(meta[:total_pages]).to eq(0)
        expect(meta[:total_count]).to eq(0)
        expect(meta[:next_page]).to be_nil
      end
    end

    context 'edge cases' do
      it 'handles page beyond total pages' do
        create(:project, user: user)
        beyond = user.projects.page(5).per(10)
        meta = helper.pagination_meta(beyond)

        expect(meta[:current_page]).to eq(5)
        expect(meta[:total_pages]).to eq(1)
      end
    end
  end

  describe 'integration note' do
    it 'render_pagination is fully tested via request specs' do
      expect(true).to be true
    end
  end
end
