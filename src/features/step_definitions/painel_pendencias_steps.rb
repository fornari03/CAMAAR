# =========================================
# Contexto (Dado)
# =========================================

Dado('que eu sou um aluno matriculado na turma {string}') do |nome_turma|
  setup_student_enrollment(nome_turma)
end

Dado('que o administrador distribuiu o template {string} para a turma {string}') do |nome_template, nome_turma|
  distribute_template_to_class(nome_template)
end

Dado('que eu ainda não respondi a este formulário') do
  ensure_response_is_pending
end

Dado('que eu estou logado como aluno') do
  mock_student_login
end

Dado('que eu já respondi a avaliação {string} da turma {string}') do |nome_template, nome_turma|
  mark_response_as_submitted
end

# =========================================
# Ações (Quando)
# =========================================

Quando('eu acesso o meu painel de avaliações') do
  visit avaliacoes_path
end

# =========================================
# Verificações (Então)
# =========================================

Então('eu devo ver {string} na lista de pendências') do |titulo_template|
  expect(page).to have_content(titulo_template)
end

Então('o item deve indicar a turma {string}') do |codigo_turma|
  expect(page).to have_content(@turma.codigo)
end

Então('eu devo ver um link para {string}') do |texto_link|
  expect(page).to have_link(texto_link)
end

Então('eu não devo ver {string} na lista de pendências') do |titulo_template|
  expect(page).not_to have_content(titulo_template)
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

def setup_student_enrollment(nome_turma)
  materia = Materia.create!(nome: nome_turma, codigo: "MAT_PEND")
  
  docente = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Prof. Teste", email: "prof_teste@test.com", matricula: "PROF123", 
    usuario: "prof_teste", password: "password", ocupacao: :docente, status: true
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

def distribute_template_to_class(nome_template)
  @template = Template.create!(
    name: nome_template, 
    titulo: nome_template, 
    id_criador: Usuario.first.id, 
    participantes: 'todos'
  )
  @turma.distribuir_formulario(@template)
end

def ensure_response_is_pending
  form = @turma.formularios.last
  resposta = Resposta.find_by(formulario: form, participante: @meu_usuario)
  resposta.update!(data_submissao: nil)
end

def mock_student_login
  allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(@meu_usuario)
end

def mark_response_as_submitted
  form = @turma.formularios.last
  resposta = Resposta.find_by(formulario: form, participante: @meu_usuario)
  resposta.update!(data_submissao: Time.now)
end