Dado('que existe um template de avaliação {string}') do |nome_template|
  admin = Usuario.find_by(ocupacao: :admin) || Usuario.create!(
    nome: 'Admin', email: 'admin@test.com', matricula: '000', 
    usuario: 'admin', password: 'password', ocupacao: :admin, status: true
  )
  
  @template = Template.find_or_create_by!(name: nome_template) do |t|
    t.titulo = nome_template
    t.id_criador = admin.id
    t.participantes = 'todos'
    t.hidden = false
  end
end

Dado('que existe a turma {string} com {int} alunos matriculados') do |nome_turma, num_alunos|
  # 1. Prepara Matéria, Docente e Turma
  turma = setup_academic_structure(nome_turma)

  # 2. Cria os alunos e gera as matrículas
  enroll_batch_students(turma, num_alunos)
end

Dado('que eu estou na página de distribuição de formulários') do
  visit formularios_path
end

Quando('eu seleciono o template de avaliação {string}') do |nome_template|
  select nome_template, from: 'template_id'
end

Quando('eu seleciono as turmas para distribuição {string} e {string}') do |turma1, turma2|
  materia1 = Materia.find_by(nome: turma1)
  t1 = Turma.where(materia: materia1).first
  
  materia2 = Materia.find_by(nome: turma2)
  t2 = Turma.where(materia: materia2).first
  
  check "turma_#{t1.id}"
  check "turma_#{t2.id}"
end

Quando('eu clico no botão de distribuição {string}') do |nome_botao|
  click_button nome_botao
end

Então('eu devo ver a mensagem de sucesso de distribuição {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('eu devo ver a mensagem de erro de distribuição {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('a turma {string} deve ter um formulário associado ao template {string}') do |nome_turma, nome_template|
  materia = Materia.find_by(nome: nome_turma)
  turma = Turma.where(materia: materia).first
  template = Template.find_by(name: nome_template)
  
  expect(turma.formularios.where(template: template)).to exist
end

Então('todos os {int} alunos da turma {string} devem ter uma resposta pendente para este formulário') do |num_alunos, nome_turma|
  materia = Materia.find_by(nome: nome_turma)
  turma = Turma.where(materia: materia).first
  
  form = turma.formularios.last
  expect(Resposta.where(formulario: form, data_submissao: nil).count).to be >= num_alunos
end

Quando('eu seleciono o template {string} e clico em Distribuir') do |template|
  select template, from: 'template_id'
  click_button 'Distribuir Formulário'
end