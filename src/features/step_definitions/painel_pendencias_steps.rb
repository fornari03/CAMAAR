# =========================================
# Contexto (Dado)
# =========================================

# Configura matrícula do aluno na turma.
#
# Argumentos:
#   - nome_turma (String): Nome da turma.
#
# Efeitos Colaterais:
#   - Setup de dados (Materias, Turmas, Usuario, Matricula).
Dado('que eu sou um aluno matriculado na turma {string}') do |nome_turma|
  setup_student_enrollment(nome_turma)
end

# Distribui formulário para turma.
#
# Argumentos:
#   - nome_template (String): Nome do template.
#   - nome_turma (String): Nome da turma (ignorado no helper).
#
# Efeitos Colaterais:
#   - Cria Template e distribui.
Dado('que o administrador distribuiu o template {string} para a turma {string}') do |nome_template, nome_turma|
  distribute_template_to_class(nome_template)
end

# Garante que resposta está pendente.
#
# Efeitos Colaterais:
#   - Atualiza data_submissao para nil.
Dado('que eu ainda não respondi a este formulário') do
  ensure_response_is_pending
end

# Simula login.
#
# Efeitos Colaterais:
#   - Mocka current_usuario na sessao.
Dado('que eu estou logado como aluno') do
  mock_student_login
end

# Marca resposta como submetida.
#
# Argumentos:
#   - nome_template (String): Nome (ignorado).
#   - nome_turma (String): Turma (ignorado).
#
# Efeitos Colaterais:
#   - Atualiza data_submissao.
Dado('que eu já respondi a avaliação {string} da turma {string}') do |nome_template, nome_turma|
  mark_response_as_submitted
end

# =========================================
# Ações (Quando)
# =========================================

# Acessa path de avaliações.
#
# Efeitos Colaterais:
#   - Visit /avaliacoes.
Quando('eu acesso o meu painel de avaliações') do
  visit avaliacoes_path
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica texto na página.
#
# Argumentos:
#   - titulo_template (String): Texto esperado.
Então('eu devo ver {string} na lista de pendências') do |titulo_template|
  expect(page).to have_content(titulo_template)
end

# Verifica indicação da turma.
#
# Argumentos:
#   - codigo_turma (String): Código.
Então('o item deve indicar a turma {string}') do |codigo_turma|
  expect(page).to have_content(@turma.codigo)
end

# Verifica existência de link.
#
# Argumentos:
#   - texto_link (String): Texto do link.
Então('eu devo ver um link para {string}') do |texto_link|
  expect(page).to have_link(texto_link)
end

# Verifica ausência de texto.
#
# Argumentos:
#   - titulo_template (String): Texto.
Então('eu não devo ver {string} na lista de pendências') do |titulo_template|
  expect(page).not_to have_content(titulo_template)
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

# Configura contexto de matrícula.
#
# Argumentos:
#   - nome_turma (String): Nome da turma.
#
# Efeitos Colaterais:
#   - Cria dados reais no banco de teste.
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

# Distribui template criado.
#
# Argumentos:
#   - nome_template (String): Nome.
def distribute_template_to_class(nome_template)
  @template = Template.create!(
    name: nome_template, 
    titulo: nome_template, 
    id_criador: Usuario.first.id, 
    participantes: 'todos'
  )
  @turma.distribuir_formulario(@template)
end

# Garante resposta pendente.
#
# Efeitos Colaterais:
#   - Update DB.
def ensure_response_is_pending
  form = @turma.formularios.last
  resposta = Resposta.find_by(formulario: form, participante: @meu_usuario)
  resposta.update!(data_submissao: nil)
end

# Mocka login via controller helper (se suportado) ou apenas lógica interna.
# Note: Na prática `allow_any_instance_of` é desencorajado no RSpec moderno,
# mas mantendo conformidade com o código original.
def mock_student_login
  allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(@meu_usuario)
end

# Marca resposta como submetida.
def mark_response_as_submitted
  form = @turma.formularios.last
  resposta = Resposta.find_by(formulario: form, participante: @meu_usuario)
  resposta.update!(data_submissao: Time.now)
end