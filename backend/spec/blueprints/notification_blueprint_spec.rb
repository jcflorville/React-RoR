require 'rails_helper'

RSpec.describe NotificationBlueprint, type: :blueprint do
  let(:user) { create(:user, name: 'John Doe') }
  let(:actor) { create(:user, name: 'Jane Smith') }
  let(:project) { create(:project, user: user) }
  let(:task) { create(:task, project: project, user: user, title: 'Fix bug') }
  let(:notification) do
    create(:notification,
      user: user,
      actor: actor,
      notifiable: task,
      event_type: :task_assigned,
      metadata: { task_title: task.title, project_id: project.id }
    )
  end

  describe 'serialization' do
    subject(:serialized) { JSON.parse(NotificationBlueprint.render(notification)) }

    it 'includes identifier' do
      expect(serialized['id']).to eq(notification.id)
    end

    it 'includes basic fields' do
      expect(serialized).to include(
        'event_type' => 'task_assigned',
        'metadata' => { 'task_title' => task.title, 'project_id' => project.id }
      )
      expect(serialized).to have_key('created_at')
      expect(serialized).to have_key('updated_at')
    end

    it 'includes computed read field' do
      expect(serialized['read']).to eq(false)
      expect(serialized['unread']).to eq(true)
    end

    it 'includes message' do
      expect(serialized['message']).to eq("Jane Smith assigned you to \"Fix bug\"")
    end

    it 'includes url' do
      expect(serialized['url']).to include('/projects/')
      expect(serialized['url']).to include('/tasks/')
    end

    context 'when notification is read' do
      before { notification.mark_as_read! }

      it 'reflects read status' do
        result = JSON.parse(NotificationBlueprint.render(notification))
        expect(result['read']).to eq(true)
        expect(result['unread']).to eq(false)
        expect(result['read_at']).to be_present
      end
    end

    context 'with include actor' do
      subject(:serialized) do
        JSON.parse(NotificationBlueprint.render(notification, include: [ :actor ]))
      end

      it 'includes actor data' do
        expect(serialized['actor']).to be_present
        expect(serialized['actor']['id']).to eq(actor.id)
        expect(serialized['actor']['name']).to eq('Jane Smith')
      end
    end

    context 'with include notifiable' do
      subject(:serialized) do
        JSON.parse(NotificationBlueprint.render(notification, include: [ :notifiable ]))
      end

      it 'includes notifiable task data' do
        expect(serialized['notifiable']).to be_present
        expect(serialized['notifiable']['id']).to eq(task.id)
        expect(serialized['notifiable']['title']).to eq('Fix bug')
      end
    end

    context 'without includes' do
      it 'does not include associations by default' do
        expect(serialized).not_to have_key('actor')
        expect(serialized).not_to have_key('notifiable')
      end
    end
  end

  describe 'collection serialization' do
    let!(:notifications) do
      [
        create(:notification, user: user, actor: actor, notifiable: task),
        create(:notification, user: user, actor: actor, notifiable: task, event_type: :mention)
      ]
    end

    subject(:serialized) { JSON.parse(NotificationBlueprint.render(notifications)) }

    it 'serializes multiple notifications' do
      expect(serialized).to be_an(Array)
      expect(serialized.length).to eq(2)
    end

    it 'includes all notification data' do
      expect(serialized.first).to have_key('id')
      expect(serialized.first).to have_key('event_type')
      expect(serialized.first).to have_key('message')
    end
  end
end
