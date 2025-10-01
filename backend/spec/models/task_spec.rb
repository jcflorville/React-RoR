require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(2).is_at_most(200) }
    it { should validate_length_of(:description).is_at_most(2000) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(todo: 0, in_progress: 1, completed: 2, blocked: 3) }
    it { should define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2, urgent: 3) }
  end

  describe 'scopes' do
    let!(:task1) { create(:task, created_at: 2.days.ago) }
    let!(:task2) { create(:task, created_at: 1.day.ago) }
    let!(:todo_task) { create(:task, status: :todo) }
    let!(:completed_task) { create(:task, status: :completed) }
    let!(:high_priority) { create(:task, priority: :high) }
    let!(:overdue_task) { create(:task, due_date: 1.week.ago, status: :todo) }

    describe '.ordered' do
      it 'orders tasks by created_at' do
        expect(Task.ordered.first).to eq(task1)
      end
    end

    describe '.by_status' do
      it 'filters by status' do
        expect(Task.by_status(:todo)).to include(todo_task)
        expect(Task.by_status(:todo)).not_to include(completed_task)
      end
    end

    describe '.overdue' do
      it 'returns overdue tasks that are not completed' do
        expect(Task.overdue).to include(overdue_task)
        expect(Task.overdue).not_to include(completed_task)
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation :set_defaults' do
      let(:task) { build(:task, status: nil, priority: nil) }

      it 'sets default status to todo' do
        task.save
        expect(task.status).to eq('todo')
      end

      it 'sets default priority to medium' do
        task.save
        expect(task.priority).to eq('medium')
      end
    end

    describe 'before_update :set_completed_at' do
      let(:task) { create(:task, status: :todo) }

      it 'sets completed_at when status changes to completed' do
        task.update(status: :completed)
        expect(task.completed_at).to be_present
      end

      it 'clears completed_at when status changes from completed' do
        task.update(status: :completed)
        expect(task.completed_at).to be_present

        task.update(status: :todo)
        expect(task.completed_at).to be_nil
      end
    end
  end

  describe 'instance methods' do
    describe '#overdue?' do
      context 'when task has no due_date' do
        let(:task) { create(:task, due_date: nil) }

        it 'returns false' do
          expect(task.overdue?).to be false
        end
      end

      context 'when task is completed' do
        let(:task) { create(:task, :completed, due_date: 1.week.ago) }

        it 'returns false' do
          expect(task.overdue?).to be false
        end
      end

      context 'when task due_date is in the past and not completed' do
        let(:task) { create(:task, status: :todo, due_date: 1.week.ago) }

        it 'returns true' do
          expect(task.overdue?).to be true
        end
      end
    end

    describe '#days_until_due' do
      context 'when task has no due_date' do
        let(:task) { create(:task, due_date: nil) }

        it 'returns nil' do
          expect(task.days_until_due).to be_nil
        end
      end

      context 'when task due_date is in the future' do
        let(:task) { create(:task, due_date: 5.days.from_now) }

        it 'returns positive days' do
          expect(task.days_until_due).to eq(5)
        end
      end

      context 'when task due_date is in the past' do
        let(:task) { create(:task, due_date: 3.days.ago) }

        it 'returns negative days' do
          expect(task.days_until_due).to eq(-3)
        end
      end
    end
  end

  describe 'pg_search' do
    let!(:task1) { create(:task, title: 'Implement React components', description: 'Building UI components') }
    let!(:task2) { create(:task, title: 'Setup Rails API', description: 'Backend development') }
    let!(:task3) { create(:task, title: 'Mobile features', description: 'React Native components') }

    it 'searches by title' do
      results = Task.search_by_content('React')
      expect(results).to include(task1, task3)
      expect(results).not_to include(task2)
    end

    it 'searches by description' do
      results = Task.search_by_content('Backend')
      expect(results).to include(task2)
      expect(results).not_to include(task1, task3)
    end
  end
end
