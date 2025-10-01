# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Iniciando seeds..."

# Limpar dados existentes em desenvolvimento
if Rails.env.development?
  puts "🧹 Limpando dados existentes..."
  Comment.destroy_all
  Task.destroy_all
  Project.destroy_all
  Category.destroy_all
  User.where.not(email: 'admin@test.com').destroy_all
end

# 1. Criar usuários
puts "👥 Criando usuários..."

admin = User.find_or_create_by!(email: 'admin@test.com') do |user|
  user.name = 'Administrador'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

users = []
[ 'João Silva', 'Maria Santos', 'Carlos Oliveira', 'Ana Costa' ].each do |name|
  email = "#{name.downcase.gsub(' ', '.')}@test.com"
  user = User.find_or_create_by!(email: email) do |u|
    u.name = name
    u.password = 'password123'
    u.password_confirmation = 'password123'
  end
  users << user
end

puts "✅ #{User.count} usuários criados"

# 2. Criar categorias
puts "🏷️ Criando categorias..."

categories_data = [
  { name: 'Frontend', color: '#3B82F6', description: 'Desenvolvimento de interfaces e experiência do usuário' },
  { name: 'Backend', color: '#EF4444', description: 'APIs, servidores e lógica de negócio' },
  { name: 'DevOps', color: '#10B981', description: 'Infraestrutura, deploy e monitoramento' },
  { name: 'Mobile', color: '#8B5CF6', description: 'Aplicações móveis iOS e Android' },
  { name: 'Design', color: '#F59E0B', description: 'UI/UX Design e prototipagem' },
  { name: 'QA', color: '#6B7280', description: 'Testes e qualidade de software' }
]

categories = categories_data.map do |cat_data|
  Category.find_or_create_by!(name: cat_data[:name]) do |category|
    category.color = cat_data[:color]
    category.description = cat_data[:description]
  end
end

puts "✅ #{Category.count} categorias criadas"

# 3. Criar projetos
puts "📋 Criando projetos..."

projects_data = [
  {
    name: 'Sistema de Gestão de Projetos',
    description: 'Plataforma completa para gerenciamento de projetos e tarefas com interface moderna',
    status: 'active',
    priority: 'high',
    start_date: 2.weeks.ago,
    end_date: 2.months.from_now,
    categories: [ 'Frontend', 'Backend' ]
  },
  {
    name: 'App Mobile E-commerce',
    description: 'Aplicativo móvel para vendas online com integração de pagamentos',
    status: 'active',
    priority: 'urgent',
    start_date: 1.month.ago,
    end_date: 1.month.from_now,
    categories: [ 'Mobile', 'Backend' ]
  },
  {
    name: 'Redesign do Website',
    description: 'Modernização completa da interface e experiência do usuário',
    status: 'draft',
    priority: 'medium',
    start_date: 1.week.from_now,
    end_date: 3.months.from_now,
    categories: [ 'Design', 'Frontend' ]
  },
  {
    name: 'Infraestrutura na Nuvem',
    description: 'Migração dos serviços para cloud com monitoramento avançado',
    status: 'completed',
    priority: 'high',
    start_date: 3.months.ago,
    end_date: 1.week.ago,
    categories: [ 'DevOps' ]
  }
]

projects = projects_data.map do |proj_data|
  user = [ admin, *users ].sample
  project = Project.create!(
    name: proj_data[:name],
    description: proj_data[:description],
    status: proj_data[:status],
    priority: proj_data[:priority],
    start_date: proj_data[:start_date],
    end_date: proj_data[:end_date],
    user: user
  )

  # Associar categorias
  proj_categories = categories.select { |cat| proj_data[:categories].include?(cat.name) }
  project.categories = proj_categories

  project
end

puts "✅ #{Project.count} projetos criados"

# 4. Criar tarefas
puts "📝 Criando tarefas..."

tasks_data = [
  # Sistema de Gestão de Projetos
  { title: 'Configurar ambiente de desenvolvimento', description: 'Setup inicial do Rails e React', status: 'completed', priority: 'high' },
  { title: 'Criar models e migrations', description: 'Estruturar banco de dados', status: 'completed', priority: 'high' },
  { title: 'Implementar autenticação', description: 'JWT auth com Devise', status: 'completed', priority: 'urgent' },
  { title: 'Desenvolver CRUD de projetos', description: 'Controllers e endpoints da API', status: 'in_progress', priority: 'high' },
  { title: 'Interface de listagem', description: 'Componentes React para listar projetos', status: 'todo', priority: 'medium' },
  { title: 'Dashboard analytics', description: 'Gráficos e estatísticas', status: 'todo', priority: 'low' },

  # App Mobile E-commerce
  { title: 'Setup React Native', description: 'Configuração inicial do projeto mobile', status: 'completed', priority: 'urgent' },
  { title: 'Integração de pagamentos', description: 'Stripe e PayPal integration', status: 'in_progress', priority: 'urgent' },
  { title: 'Catálogo de produtos', description: 'Listagem e busca de produtos', status: 'in_progress', priority: 'high' },
  { title: 'Carrinho de compras', description: 'Funcionalidade de carrinho', status: 'todo', priority: 'high' },

  # Redesign do Website
  { title: 'Pesquisa de usuários', description: 'Entender necessidades dos usuários', status: 'todo', priority: 'medium' },
  { title: 'Protótipos no Figma', description: 'Criar wireframes e protótipos', status: 'todo', priority: 'medium' },

  # Infraestrutura na Nuvem
  { title: 'Setup AWS', description: 'Configurar conta e recursos', status: 'completed', priority: 'high' },
  { title: 'Deploy automatizado', description: 'CI/CD com GitHub Actions', status: 'completed', priority: 'high' },
  { title: 'Monitoramento', description: 'Setup de logs e alertas', status: 'completed', priority: 'medium' }
]

projects.each_with_index do |project, proj_index|
  tasks_for_project = case proj_index
  when 0 then tasks_data[0..5]   # Sistema de Gestão
  when 1 then tasks_data[6..9]   # App Mobile
  when 2 then tasks_data[10..11] # Redesign
  when 3 then tasks_data[12..14] # Infraestrutura
  end

  tasks_for_project.each do |task_data|
    assignee = [ admin, *users ].sample
    due_date = case task_data[:status]
    when 'completed' then rand(1..30).days.ago
    when 'in_progress' then rand(1..14).days.from_now
    when 'todo' then rand(7..60).days.from_now
    else rand(1..30).days.from_now
    end

    Task.create!(
      title: task_data[:title],
      description: task_data[:description],
      status: task_data[:status],
      priority: task_data[:priority],
      due_date: due_date,
      completed_at: task_data[:status] == 'completed' ? rand(1..30).days.ago : nil,
      project: project,
      user: assignee
    )
  end
end

puts "✅ #{Task.count} tarefas criadas"

# 5. Criar comentários
puts "💬 Criando comentários..."

comments_data = [
  'Ótimo progresso! Continue assim.',
  'Precisamos revisar essa abordagem.',
  'Implementação concluída com sucesso.',
  'Encontrei alguns problemas nos testes.',
  'Documentação atualizada.',
  'Aguardando aprovação do cliente.',
  'Bloqueado por dependência externa.',
  'Excelente trabalho na implementação!',
  'Sugestão: adicionar validação extra.',
  'Ready for review.'
]

Task.all.each do |task|
  # Cada tarefa pode ter 0-3 comentários
  rand(0..3).times do
    commenter = [ admin, *users ].sample
    content = comments_data.sample

    Comment.create!(
      content: content,
      task: task,
      user: commenter,
      created_at: rand(task.created_at..Time.current)
    )
  end
end

puts "✅ #{Comment.count} comentários criados"

puts "\n🎉 Seeds concluídos com sucesso!"
puts "📊 Resumo:"
puts "   👥 Usuários: #{User.count}"
puts "   🏷️ Categorias: #{Category.count}"
puts "   📋 Projetos: #{Project.count}"
puts "   📝 Tarefas: #{Task.count}"
puts "   💬 Comentários: #{Comment.count}"
puts "\n🔑 Login de teste:"
puts "   Email: admin@test.com"
puts "   Senha: password123"
