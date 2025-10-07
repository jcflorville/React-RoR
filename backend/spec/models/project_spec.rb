require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:tasks).dependent(:destroy) }
    it { should have_and_belong_to_many(:categories) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(2000) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(draft: 0, active: 1, completed: 2, archived: 3) }
    it { should define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2, urgent: 3) }
  end

  describe 'scopes' do
    let!(:project1) { create(:project, name: 'Alpha Project') }
    let!(:project2) { create(:project, name: 'Beta Project') }
    let!(:active_project) { create(:project, status: :active) }
    let!(:draft_project) { create(:project, status: :draft) }
    let!(:high_priority) { create(:project, priority: :high) }
    let!(:low_priority) { create(:project, priority: :low) }

    describe '.ordered' do
      it 'orders projects by name' do
        expect(Project.ordered).to eq([ project1, project2, active_project, draft_project, high_priority, low_priority ].sort_by(&:name))
      end
    end

    describe '.by_status' do
      it 'filters by status' do
        expect(Project.by_status(:active)).to include(active_project)
        expect(Project.by_status(:active)).not_to include(draft_project)
      end
    end

    describe '.by_priority' do
      it 'filters by priority' do
        expect(Project.by_priority(:high)).to include(high_priority)
        expect(Project.by_priority(:high)).not_to include(low_priority)
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation :set_defaults' do
      let(:project) { build(:project, status: nil, priority: nil, start_date: nil) }

      it 'sets default status to draft' do
        project.save
        expect(project.status).to eq('draft')
      end

      it 'sets default priority to medium' do
        project.save
        expect(project.priority).to eq('medium')
      end

      it 'sets default start_date to current date' do
        project.save
        expect(project.start_date).to eq(Date.current)
      end
    end
  end

  describe 'custom validations' do
    describe '#end_date_after_start_date' do
      it 'is valid when end_date is after start_date' do
        project = build(:project, start_date: Date.current, end_date: 1.week.from_now)
        expect(project).to be_valid
      end

      it 'is invalid when end_date is before start_date' do
        project = build(:project, start_date: Date.current, end_date: 1.week.ago)
        expect(project).not_to be_valid
        expect(project.errors[:end_date]).to include('deve ser posterior à data de início')
      end
    end
  end

  describe 'instance methods' do
    let(:project) { create(:project) }

    # describe '#progress_percentage' do
    #   context 'when project has no tasks' do
    #     it 'returns 0' do
    #       expect(project.progress_percentage).to eq(0)
    #     end
    #   end

    #   context 'when project has tasks' do
    #     before do
    #       create_list(:task, 2, project: project, status: :completed)
    #       create_list(:task, 2, project: project, status: :todo)
    #     end

    #     it 'calculates the correct percentage' do
    #       expect(project.progress_percentage).to eq(50.0)
    #     end
    #   end
    # end

    describe '#overdue?' do
      context 'when project has no end_date' do
        let(:project) { create(:project, end_date: nil) }

        it 'returns false' do
          expect(project.overdue?).to be false
        end
      end

      context 'when project is completed' do
        let(:project) { create(:project, :completed, end_date: 1.week.ago) }

        it 'returns false' do
          expect(project.overdue?).to be false
        end
      end

      context 'when project end_date is in the past and not completed' do
        let(:project) { create(:project, status: :active, end_date: 1.week.ago) }

        it 'returns true' do
          expect(project.overdue?).to be true
        end
      end

      context 'when project end_date is in the future' do
        let(:project) { create(:project, end_date: 1.week.from_now) }

        it 'returns false' do
          expect(project.overdue?).to be false
        end
      end
    end
  end

  describe 'pg_search' do
    let!(:project1) { create(:project, name: 'React Frontend', description: 'Building user interfaces') }
    let!(:project2) { create(:project, name: 'Rails API', description: 'Backend development') }
    let!(:project3) { create(:project, name: 'Mobile App', description: 'React Native application') }

    it 'searches by name' do
      results = Project.search_by_content('React')
      expect(results).to include(project1, project3)
      expect(results).not_to include(project2)
    end

    it 'searches by description' do
      results = Project.search_by_content('Backend')
      expect(results).to include(project2)
      expect(results).not_to include(project1, project3)
    end

    it 'is case insensitive' do
      results = Project.search_by_content('react')
      expect(results).to include(project1, project3)
    end
  end
end
