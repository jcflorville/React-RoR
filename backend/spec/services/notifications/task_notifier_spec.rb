# spec/services/notifications/task_notifier_spec.rb
require 'rails_helper'

RSpec.describe Notifications::TaskNotifier, type: :service do
  describe '.call' do
    let(:task_owner) { create(:user) }
    let(:actor) { create(:user) }
    let(:project) { create(:project, user: task_owner) }
    let(:task) { create(:task, project: project, user: task_owner, status: :todo) }

    context 'when status changes to in_progress' do
      let(:changes) { { status: [ 'todo', 'in_progress' ] } }

      before do
        task.update(status: :in_progress)
      end

      it 'creates task_status_changed notification' do
        expect {
          described_class.call(task: task, actor: actor, changes: changes)
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.event_type).to eq('task_status_changed')
        expect(notification.user).to eq(task_owner)
        expect(notification.actor).to eq(actor)
      end

      it 'includes status change metadata' do
        described_class.call(task: task, actor: actor, changes: changes)

        notification = Notification.last
        expect(notification.metadata['old_status']).to eq('todo')
        expect(notification.metadata['new_status']).to eq('in_progress')
        expect(notification.metadata['task_title']).to eq(task.title)
        expect(notification.metadata['project_name']).to eq(project.name)
      end

      it 'enqueues webhook delivery job' do
        expect {
          described_class.call(task: task, actor: actor, changes: changes)
        }.to have_enqueued_job(WebhookDeliveryJob).exactly(1).times
      end

      it 'returns success with notification count' do
        result = described_class.call(task: task, actor: actor, changes: changes)

        expect(result.success?).to be true
        expect(result.data[:notifications_count]).to eq(1)
        expect(result.message).to eq('1 notification(s) created')
      end
    end

    context 'when status changes to completed' do
      let(:changes) { { status: [ 'in_progress', 'completed' ] } }

      before do
        task.update(status: :in_progress)
        task.update(status: :completed)
      end

      it 'creates both task_status_changed and task_completed notifications' do
        expect {
          described_class.call(task: task, actor: actor, changes: changes)
        }.to change(Notification, :count).by(2)

        status_notification = Notification.find_by(event_type: 'task_status_changed')
        completed_notification = Notification.find_by(event_type: 'task_completed')

        expect(status_notification).to be_present
        expect(completed_notification).to be_present
        expect(status_notification.user).to eq(task_owner)
        expect(completed_notification.user).to eq(task_owner)
      end

      it 'includes completed_at in task_completed metadata' do
        described_class.call(task: task, actor: actor, changes: changes)

        notification = Notification.find_by(event_type: 'task_completed')
        expect(notification.metadata['completed_at']).to be_present
        expect(notification.metadata['task_title']).to eq(task.title)
      end

      it 'enqueues webhook delivery jobs for both notifications' do
        expect {
          described_class.call(task: task, actor: actor, changes: changes)
        }.to have_enqueued_job(WebhookDeliveryJob).exactly(2).times
      end
    end

    context 'when task owner is the actor' do
      let(:changes) { { status: [ 'todo', 'in_progress' ] } }

      before do
        task.update(status: :in_progress)
      end

      it 'does not create notifications' do
        expect {
          described_class.call(task: task, actor: task_owner, changes: changes)
        }.not_to change(Notification, :count)
      end

      it 'returns success with zero notifications' do
        result = described_class.call(task: task, actor: task_owner, changes: changes)

        expect(result.success?).to be true
        expect(result.data[:notifications_count]).to eq(0)
      end
    end

    context 'when no status change' do
      let(:changes) { { title: [ 'Old Title', 'New Title' ] } }

      it 'does not create notifications' do
        expect {
          described_class.call(task: task, actor: actor, changes: changes)
        }.not_to change(Notification, :count)
      end

      it 'returns success with zero notifications' do
        result = described_class.call(task: task, actor: actor, changes: changes)

        expect(result.success?).to be true
        expect(result.data[:notifications_count]).to eq(0)
      end
    end

    context 'with empty changes' do
      let(:changes) { {} }

      it 'does not create notifications' do
        expect {
          described_class.call(task: task, actor: actor, changes: changes)
        }.not_to change(Notification, :count)
      end
    end

    context 'with malformed status change' do
      let(:changes) { { status: 'in_progress' } } # Not an array

      it 'does not create notifications' do
        expect {
          described_class.call(task: task, actor: actor, changes: changes)
        }.not_to change(Notification, :count)
      end
    end
  end
end
