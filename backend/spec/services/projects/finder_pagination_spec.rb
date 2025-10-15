require 'rails_helper'

RSpec.describe Projects::Finder, type: :service do
  describe 'pagination' do
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

    context 'when no pagination params are provided' do
      it 'returns first page with default per_page (10)' do
        result = described_class.call(user: user, params: {})

        expect(result.success?).to be true
        expect(result.data).to be_a(ActiveRecord::Relation)
        expect(result.data.size).to eq(10)
        expect(result.data.current_page).to eq(1)
        expect(result.data.total_pages).to eq(3)
      end

      it 'returns Kaminari paginated collection' do
        result = described_class.call(user: user, params: {})

        expect(result.data).to respond_to(:current_page)
        expect(result.data).to respond_to(:total_pages)
        expect(result.data).to respond_to(:limit_value)
        expect(result.data).to respond_to(:total_count)
        expect(result.data).to respond_to(:next_page)
      end
    end

    context 'when page parameter is provided' do
      it 'returns the requested page' do
        result = described_class.call(user: user, params: { page: 2 })

        expect(result.success?).to be true
        expect(result.data.current_page).to eq(2)
        expect(result.data.size).to eq(10)
      end

      it 'returns last page with remaining records' do
        result = described_class.call(user: user, params: { page: 3 })

        expect(result.success?).to be true
        expect(result.data.current_page).to eq(3)
        expect(result.data.size).to eq(5)
      end

      it 'handles page beyond total pages' do
        result = described_class.call(user: user, params: { page: 10 })

        expect(result.success?).to be true
        expect(result.data.size).to eq(0)
        expect(result.data.current_page).to eq(10)
      end

      it 'handles invalid page numbers gracefully' do
        result = described_class.call(user: user, params: { page: 0 })

        expect(result.success?).to be true
        expect(result.data.current_page).to eq(1)
      end
    end

    context 'when per_page parameter is provided' do
      it 'returns custom number of items per page' do
        result = described_class.call(user: user, params: { per_page: 5 })

        expect(result.success?).to be true
        expect(result.data.size).to eq(5)
        expect(result.data.limit_value).to eq(5)
        expect(result.data.total_pages).to eq(5)
      end

      it 'handles large per_page values' do
        result = described_class.call(user: user, params: { per_page: 100 })

        expect(result.success?).to be true
        expect(result.data.size).to eq(25)
        expect(result.data.total_pages).to eq(1)
      end

      it 'handles invalid per_page values' do
        result = described_class.call(user: user, params: { per_page: 0 })

        expect(result.success?).to be true
        expect(result.data).to be_a(ActiveRecord::Relation)
      end
    end

    context 'pagination with filters' do
      let!(:active_projects) do
        10.times.map { |i| create(:project, user: user, status: :active, name: "Active #{i}") }
      end

      let!(:completed_projects) do
        5.times.map { |i| create(:project, user: user, status: :completed, name: "Completed #{i}") }
      end

      it 'paginates filtered results' do
        result = described_class.call(
          user: user,
          params: { status: 'active', page: 1, per_page: 5 }
        )

        expect(result.success?).to be true
        expect(result.data.size).to eq(5)
        expect(result.data.total_count).to be >= 10
        expect(result.data.total_pages).to be >= 2
        expect(result.data.all? { |p| p.status == 'active' }).to be true
      end

      it 'paginates search results' do
        result = described_class.call(
          user: user,
          params: { search: 'Active', page: 2, per_page: 3 }
        )

        expect(result.success?).to be true
        expect(result.data.size).to eq(3)
        expect(result.data.current_page).to eq(2)
      end
    end

    context 'pagination with sorting' do
      it 'maintains sort order across pages' do
        result_page1 = described_class.call(
          user: user,
          params: { sort: 'name_asc', page: 1, per_page: 10 }
        )

        result_page2 = described_class.call(
          user: user,
          params: { sort: 'name_asc', page: 2, per_page: 10 }
        )

        expect(result_page1.success?).to be true
        expect(result_page2.success?).to be true

        last_of_page1 = result_page1.data.last.name
        first_of_page2 = result_page2.data.first.name

        expect(first_of_page2).to be > last_of_page1
      end
    end

    context 'next_page metadata' do
      it 'returns next_page number when more pages exist' do
        result = described_class.call(user: user, params: { page: 1, per_page: 10 })

        expect(result.success?).to be true
        expect(result.data.next_page).to eq(2)
      end

      it 'returns nil for next_page on last page' do
        result = described_class.call(user: user, params: { page: 3, per_page: 10 })

        expect(result.success?).to be true
        expect(result.data.next_page).to be_nil
      end

      it 'returns next_page correctly for custom per_page' do
        result = described_class.call(user: user, params: { page: 2, per_page: 5 })

        expect(result.success?).to be true
        expect(result.data.next_page).to eq(3)
      end
    end

    context 'edge cases' do
      it 'handles empty results with pagination' do
        other_user = create(:user)
        result = described_class.call(user: other_user, params: { page: 1, per_page: 10 })

        expect(result.success?).to be true
        expect(result.data.size).to eq(0)
        expect(result.data.total_pages).to eq(0)
        expect(result.data.next_page).to be_nil
      end

      it 'handles single result pagination' do
        single_user = create(:user)
        create(:project, user: single_user)

        result = described_class.call(user: single_user, params: { page: 1, per_page: 10 })

        expect(result.success?).to be true
        expect(result.data.size).to eq(1)
        expect(result.data.total_pages).to eq(1)
        expect(result.data.next_page).to be_nil
      end
    end

    context 'performance considerations' do
      it 'returns correct page size limiting database load' do
        result = described_class.call(user: user, params: { page: 2, per_page: 10 })

        expect(result.success?).to be true
        expect(result.data.size).to eq(10)
        expect(result.data.current_page).to eq(2)
      end

      it 'eager loads associations efficiently' do
        projects.first.categories << create(:category)
        create(:task, project: projects.first)

        result = described_class.call(user: user, params: { page: 1 })

        expect(result.data.first.association(:tasks)).to be_loaded
        expect(result.data.first.association(:categories)).to be_loaded
      end
    end
  end
end
