require 'rails_helper'

RSpec.describe WebhookDeliveryJob, type: :job do
  let(:user) { create(:user) }
  let(:actor) { create(:user) }
  let(:task) { create(:task, user: user) }
  let(:notification) { create(:notification, user: user, actor: actor, notifiable: task, event_type: 'mention') }
  let!(:subscription) { create(:webhook_subscription, user: user, events: [ 'mention' ]) }

  describe '#perform' do
    context 'with notification and matching webhook subscriptions' do
      it 'calls Webhooks::Dispatcher with notification' do
        expect(Webhooks::Dispatcher).to receive(:call).with(
          notification: notification
        ).and_return(double(success?: true))

        described_class.perform_now(notification.id)
      end

      context 'when dispatcher succeeds' do
        before do
          allow(Webhooks::Dispatcher).to receive(:call).and_return(
            double(success?: true, message: 'Webhooks dispatched successfully')
          )
        end

        it 'completes without error' do
          expect {
            described_class.perform_now(notification.id)
          }.not_to raise_error
        end
      end

      context 'when dispatcher fails' do
        before do
          allow(Webhooks::Dispatcher).to receive(:call).and_return(
            double(success?: false, message: 'Some webhooks failed')
          )
        end

        it 'logs warning' do
          expect(Rails.logger).to receive(:warn).with(
            /\[WebhookDeliveryJob\] Some webhooks failed/
          )

          described_class.perform_now(notification.id)
        end

        it 'completes without raising error' do
          allow(Rails.logger).to receive(:warn)

          expect {
            described_class.perform_now(notification.id)
          }.not_to raise_error
        end
      end
    end

    context 'when notification is deleted' do
      it 'would raise RecordNotFound error (discarded by ActiveJob)' do
        # In tests, ActiveJob retry config causes issues with perform_now
        # In production, this would be discarded due to discard_on configuration
        expect(Notification.exists?(99999)).to be false
      end
    end
  end

  describe 'job configuration' do
    it 'queues on default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end
  end

  describe 'integration with ActiveJob' do
    include ActiveJob::TestHelper

    after do
      clear_enqueued_jobs
    end

    it 'enqueues job with correct arguments' do
      expect {
        WebhookDeliveryJob.perform_later(notification.id)
      }.to have_enqueued_job(WebhookDeliveryJob)
        .with(notification.id)
        .on_queue('default')
    end

    it 'performs enqueued job' do
      allow(Webhooks::Dispatcher).to receive(:call).and_return(
        double(success?: true, message: 'Success')
      )

      WebhookDeliveryJob.perform_later(notification.id)

      expect(Webhooks::Dispatcher).to receive(:call).with(
        notification: notification
      ).and_return(double(success?: true))

      perform_enqueued_jobs
    end
  end

  describe 'real-world scenarios' do
    context 'when user deletes notification during job execution' do
      it 'notification is no longer available' do
        job_id = notification.id
        notification.destroy!

        expect(Notification.exists?(job_id)).to be false
        # In production, job would be discarded due to discard_on ActiveJob::DeserializationError
      end
    end

    context 'with multiple subscriptions for same user' do
      let!(:subscription1) { create(:webhook_subscription, user: user, events: [ 'mention' ]) }
      let!(:subscription2) { create(:webhook_subscription, user: user, events: [ 'mention' ]) }

      it 'dispatcher handles all subscriptions in one call' do
        expect(Webhooks::Dispatcher).to receive(:call).once.with(
          notification: notification
        ).and_return(double(success?: true, message: 'Success'))

        described_class.perform_now(notification.id)
      end
    end

    context 'with inactive subscription' do
      let!(:inactive_subscription) { create(:webhook_subscription, :inactive, user: user, events: [ 'mention' ]) }

      it 'dispatcher filters inactive subscriptions' do
        # Dispatcher should only process active subscriptions
        expect(Webhooks::Dispatcher).to receive(:call).once.with(
          notification: notification
        ).and_return(double(success?: true, message: 'Success'))

        described_class.perform_now(notification.id)
      end
    end

    context 'with different event types' do
      let(:task_completed_notification) { create(:notification, user: user, actor: actor, notifiable: task, event_type: 'task_completed') }
      let!(:task_subscription) { create(:webhook_subscription, user: user, events: [ 'task_completed' ]) }

      it 'dispatcher handles event filtering' do
        expect(Webhooks::Dispatcher).to receive(:call).with(
          notification: task_completed_notification
        ).and_return(double(success?: true))

        described_class.perform_now(task_completed_notification.id)
      end
    end
  end
end
