#!/usr/bin/env ruby
# Script para criar dados de teste para feature de responder formulário

puts "🔄 Carregando ambiente Rails..."
require_relative '../config/environment'

puts "🔄 Limpando dados de teste existentes..."

# Limpar apenas dados de teste
RespostaItem.destroy_all
Resposta.destroy_all
Formulario.destroy_all
Questao.destroy_all
Template.destroy_all
Matricula.destroy_all
Turma.destroy_all
Materia.destroy_all
Usuario.where("email LIKE '%@test.com'").destroy_all

puts "✅ Dados limpos\n"

puts "📝 Criando usuários..."

admin = Usuario.create!(
  nome: 'Admin Teste',
  email: 'admin@test.com',
  matricula: '000001',
  usuario: 'admin',
  password: 'senha123',
  ocupacao: :admin,
  status: true
)
puts "  ✓ Admin criado"

docente = Usuario.create!(
  nome: 'Prof. Silva',
  email: 'prof.silva@test.com',
  matricula: '100001',
  usuario: 'prof.silva',
  password: 'senha123',
  ocupacao: :docente,
  status: true
)
puts "  ✓ Docente criado"

aluno = Usuario.create!(
  nome: 'João Aluno',
  email: 'joao.aluno@test.com',
  matricula: '200001',
  usuario: 'joao.aluno',
  password: 'senha123',
  ocupacao: :discente,
  status: true
)
puts "  ✓ Aluno criado\n"

puts "📚 Criando matéria e turma..."
materia = Materia.create!(
  nome: 'Banco de Dados',
  codigo: 'CIC0105'
)

turma = Turma.create!(
  codigo: 'BD-TB',
  semestre: '2025.1',
  horario: '35T',
  materia: materia,
  docente: docente
)
puts "  ✓ Turma #{turma.codigo} criada\n"

puts "👨‍🎓 Matriculando aluno..."
Matricula.create!(
  usuario: aluno,
  turma: turma
)
puts "  ✓ Aluno matriculado em #{turma.codigo}\n"

puts "📋 Criando template..."
template = Template.create!(
  name: 'Avaliação Docente',
  titulo: 'Avaliação Docente',
  id_criador: admin.id,
  participantes: 'todos'
)

Questao.create!(
  template: template,
  enunciado: 'O professor domina o conteúdo?',
  tipo: :texto
)

Questao.create!(
  template: template,
  enunciado: 'As aulas são bem preparadas?',
  tipo: :texto
)
puts "  ✓ Template criado com #{template.questoes.count} questões\n"

puts "📝 Criando formulário..."
formulario = Formulario.create!(
  titulo_envio: 'Avaliação BD 2025.1',
  data_criacao: Time.now,
  data_encerramento: Time.now + 7.days,
  template: template,
  turma: turma
)
puts "  ✓ Formulário '#{formulario.titulo_envio}' criado\n"

puts "⏳ Criando resposta pendente..."
Resposta.create!(
  formulario: formulario,
  participante: aluno,
  data_submissao: nil
)
puts "  ✓ Resposta pendente criada\n"

puts "=" * 60
puts "✅ DADOS CRIADOS COM SUCESSO!"
puts "=" * 60
puts "\n📋 CREDENCIAIS PARA LOGIN:"
puts "  Admin:   admin@test.com / senha123"
puts "  Docente: prof.silva@test.com / senha123"
puts "  Aluno:   joao.aluno@test.com / senha123"
puts "\n🎯 FORMULÁRIO: #{formulario.titulo_envio}"
puts "📚 TURMA: #{turma.codigo}"
puts "\n🌐 Acesse: http://localhost:3000/login"
puts "=" * 60
