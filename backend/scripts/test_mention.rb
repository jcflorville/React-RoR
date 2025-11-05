# frozen_string_literal: true

# Script para testar @mention em comentários
# Uso: docker compose exec backend bash -lc 'bin/rails runner scripts/test_mention.rb'

puts "🧪 Testing @mention functionality...\n"

# Get users
admin = User.find_by(email: 'admin@test.com')
jc = User.find_by(email: 'jcflorville@test.com')

unless admin && jc
  puts "❌ Error: Users not found"
  exit 1
end

# Get a task owned by admin
task = admin.tasks.first
unless task
  puts "❌ Error: Admin has no tasks"
  exit 1
end

puts "📋 Task: #{task.title}"
puts "👤 Task Owner: #{task.user.name} (#{task.user.email})"
puts "💬 Commenter: #{jc.name} (#{jc.email})"
puts ""

# Create comment with @mention
comment_content = "Hey @#{admin.email}, I need your help with this task! Also mentioning @#{jc.email} for reference."

puts "Creating comment:"
puts "  Content: #{comment_content}"
puts ""

# Create comment directly (bypassing service for testing)
comment = Comment.create!(
  content: comment_content,
  task: task,
  user: jc
)

puts "✅ Comment created successfully (ID: #{comment.id})"
puts ""

# Now trigger the notification system
puts "🔔 Triggering notification system..."
notif_result = Notifications::CommentNotifier.call(
  comment: comment,
  actor: jc
)

if notif_result.success?
  notifications_count = notif_result.data[:notifications_count]
  puts "✅ Notifications created: #{notifications_count}"
  puts ""

  # Show what notifications were created
  puts "📊 Notifications created:"
  puts ""

  # Find mention notifications
  mention_notifs = Notification.where(
    event_type: 'mention',
    notifiable: comment
  ).includes(:user, :actor)

  mention_notifs.each do |notif|
    puts "  📧 MENTION notification:"
    puts "     Recipient: #{notif.user.name} (#{notif.user.email})"
    puts "     Actor: #{notif.actor.name}"
    puts "     Message: #{notif.message}"
    puts "     Read: #{notif.read? ? 'Yes' : 'No'}"
    puts ""
  end

  # Find comment_added notification
  comment_notif = Notification.find_by(
    event_type: 'comment_added',
    notifiable: comment
  )

  if comment_notif
    puts "  💬 COMMENT_ADDED notification:"
    puts "     Recipient: #{comment_notif.user.name} (#{comment_notif.user.email})"
    puts "     Actor: #{comment_notif.actor.name}"
    puts "     Message: #{comment_notif.message}"
    puts "     Read: #{comment_notif.read? ? 'Yes' : 'No'}"
    puts ""
  end

  # Summary
  puts "="*60
  puts "✅ Test completed successfully!"
  puts "="*60
  puts ""
  puts "📱 Next steps:"
  puts "  1. Login as admin@test.com in the frontend"
  puts "  2. Check the notification bell (should show new notifications)"
  puts "  3. Open the dropdown to see:"
  puts "     - 📧 'You were mentioned in a comment'"
  puts "     - 💬 'JC Florville commented on your task'"
  puts ""
  puts "💡 The notifications should appear INSTANTLY via SSE!"
  puts ""
else
  puts "❌ Error creating notifications: #{notif_result.message}"
  puts "   Errors: #{notif_result.errors}"
end
