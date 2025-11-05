# frozen_string_literal: true

# Script para criar notificações de teste
# Uso: docker compose exec backend bash -lc 'bin/rails runner scripts/create_test_notifications.rb'

puts "🔔 Creating test notifications..."

# Get users
users = User.order(:id).limit(2)
if users.count < 2
  puts "❌ Error: Need at least 2 users in database"
  puts "Run: docker compose exec backend bash -lc 'bin/rails db:seed'"
  exit 1
end

user1 = users.first
user2 = users.second

puts "\n👤 Users:"
puts "  User 1: #{user1.name} (#{user1.email})"
puts "  User 2: #{user2.name} (#{user2.email})"

# Create a project if needed
project = user1.projects.first_or_create!(
  name: "Test Project",
  description: "Project for testing notifications",
  status: "active",
  priority: "medium"
)

# Create tasks if needed
task1 = project.tasks.where(user: user1).first_or_create!(
  title: "Test Task for Notifications",
  description: "This task will receive comments and status changes",
  status: "pending",
  priority: "high"
)

task2 = project.tasks.where(user: user2).first_or_create!(
  title: "Another Test Task",
  description: "Task owned by user 2",
  status: "in_progress",
  priority: "medium"
)

puts "\n📋 Tasks:"
puts "  Task 1: #{task1.title} (owned by #{task1.user.name})"
puts "  Task 2: #{task2.title} (owned by #{task2.user.name})"

# Clear existing test notifications
Notification.where(user: [ user1, user2 ]).destroy_all
puts "\n🧹 Cleared existing notifications"

# 1. Create mention notification
puts "\n1️⃣ Creating mention notification..."
result = Notifications::Creator.call(
  recipient: user1,
  actor: user2,
  event_type: 'mention',
  notifiable: task1,
  metadata: { comment_content: "Hey @#{user1.email}, check this out!" }
)
puts "   ✓ Mention notification created" if result.success?

# 2. Create comment_added notification
puts "2️⃣ Creating comment_added notification..."
result = Notifications::Creator.call(
  recipient: user1,
  actor: user2,
  event_type: 'comment_added',
  notifiable: task1,
  metadata: { comment_content: "I added a comment on your task" }
)
puts "   ✓ Comment notification created" if result.success?

# 3. Create task_assigned notification
puts "3️⃣ Creating task_assigned notification..."
result = Notifications::Creator.call(
  recipient: user2,
  actor: user1,
  event_type: 'task_assigned',
  notifiable: task2,
  metadata: { task_title: task2.title }
)
puts "   ✓ Task assigned notification created" if result.success?

# 4. Create task_status_changed notification
puts "4️⃣ Creating task_status_changed notification..."
result = Notifications::Creator.call(
  recipient: user1,
  actor: user2,
  event_type: 'task_status_changed',
  notifiable: task1,
  metadata: {
    task_title: task1.title,
    old_status: 'pending',
    new_status: 'in_progress'
  }
)
puts "   ✓ Status change notification created" if result.success?

# 5. Create task_completed notification
puts "5️⃣ Creating task_completed notification..."
result = Notifications::Creator.call(
  recipient: user1,
  actor: user2,
  event_type: 'task_completed',
  notifiable: task1,
  metadata: {
    task_title: task1.title,
    completed_at: Time.current.iso8601
  }
)
puts "   ✓ Task completed notification created" if result.success?

# 6. Create project_shared notification
puts "6️⃣ Creating project_shared notification..."
result = Notifications::Creator.call(
  recipient: user2,
  actor: user1,
  event_type: 'project_shared',
  notifiable: project,
  metadata: { project_name: project.name }
)
puts "   ✓ Project shared notification created" if result.success?

# 7. Create deadline_soon notification
puts "7️⃣ Creating deadline_soon notification..."
result = Notifications::Creator.call(
  recipient: user1,
  actor: user1, # System notification
  event_type: 'deadline_soon',
  notifiable: task1,
  metadata: {
    task_title: task1.title,
    due_date: 2.days.from_now.to_date.to_s
  }
)
puts "   ✓ Deadline notification created" if result.success?

# Summary
puts "\n" + "="*60
puts "📊 Summary:"
puts "="*60
puts "Total notifications created: #{Notification.count}"
puts ""
puts "User 1 (#{user1.email}) notifications: #{user1.notifications.count}"
puts "  Unread: #{user1.notifications.unread.count}"
puts ""
puts "User 2 (#{user2.email}) notifications: #{user2.notifications.count}"
puts "  Unread: #{user2.notifications.unread.count}"
puts ""
puts "✅ Test notifications created successfully!"
puts ""
puts "🧪 Next steps:"
puts "  1. Login as #{user1.email} to see notifications"
puts "  2. Check the notification bell (should show badge)"
puts "  3. Open dropdown to see all notifications"
puts "  4. Try marking as read, deleting, etc."
puts ""
puts "🔍 To verify SSE connection:"
puts "  Open browser console and check for EventSource connection"
puts "  Should see 'ping' events every 30 seconds"
puts ""
