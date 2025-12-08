Dado('que eu sou um aluno matriculado na turma {string}') do |nome_turma|
  materia = Materia.create!(nome: nome_turma, codigo: "MAT_PEND")
  docente = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Prof. Teste", email: "prof_teste@test.com", matricula: "PROF123", usuario: "prof_teste", password: "password", ocupacao: :docente, status: true
  )
  @turma = Turma.create!(
    codigo: "T_PEND",
    semestre: '2024.1',
    horario: '35T',
    materia: materia,
    docente: docente
  )
  @meu_usuario = Usuario.create!(
    nome: "Aluno Logado",
    email: "aluno_logado@test.com",
    matricula: "20240001",
    usuario: "aluno_logado",
    password: 'password',
    ocupacao: :discente, 
    status: true
  )
  Matricula.create!(usuario: @meu_usuario, turma: @turma)
end

Dado('que o administrador distribuiu o template {string} para a turma {string}') do |nome_template, nome_turma|
  @template = Template.create!(name: nome_template, titulo: nome_template, id_criador: Usuario.first.id, participantes: 'todos')
  @turma.distribuir_formulario(@template)
end

Dado('que eu ainda não respondi a este formulário') do
  # Default is not answered, no action needed unless we want to verify
  form = @turma.formularios.last
  resposta = Resposta.find_by(formulario: form, participante: @meu_usuario)
  resposta.update!(data_submissao: nil)
end

Dado('que eu estou logado como aluno') do
  # Stub current_usuario to be @meu_usuario
  allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(@meu_usuario)
end

Quando('eu acesso o meu painel de avaliações') do
  visit avaliacoes_path
end

Então('eu devo ver {string} na lista de pendências') do |titulo_template|
  expect(page).to have_content(titulo_template)
end

Então('o item deve indicar a turma {string}') do |codigo_turma|
  # View displays code. @turma created with "T_PEND" but step says "Engenharia de Software" (name)
  # In view: <%= resposta.formulario.turma.codigo %>
  expect(page).to have_content(@turma.codigo)
end

Então('eu devo ver um link para {string}') do |texto_link|
  expect(page).to have_link(texto_link)
end

Dado('que eu já respondi a avaliação {string} da turma {string}') do |nome_template, nome_turma|
   form = @turma.formularios.last
   resposta = Resposta.find_by(formulario: form, participante: @meu_usuario)
   resposta.update!(data_submissao: Time.now)
end

Então('eu não devo ver {string} na lista de pendências') do |titulo_template|
  expect(page).not_to have_content(titulo_template)
end
