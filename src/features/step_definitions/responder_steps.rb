# =========================================
# Contexto (Dado)
# =========================================

# Loga como um usuário com papel específico.
#
# Argumentos:
#   - role (String): Papel (e.g. aluno).
#   - username (String): Nome usuário.
#
# Efeitos Colaterais:
#   - Cria Usuario, realiza login UI.
Dado('que eu sou um {string} logado como {string}') do |role, username|
  ocupacao = resolve_responder_occupation(role)
  @user = find_or_create_responder_user(username, ocupacao)
  perform_ui_login(@user.email, 'password')
end

# Matricula usuario na turma.
#
# Argumentos:
#   - turma_nome (String): Nome da turma.
#
# Efeitos Colaterais:
#   - Cria Turma, Materia, Matricula.
Dado('eu estou matriculado na turma {string}') do |turma_nome|
  create_student_enrollment(turma_nome)
end

# Cria formulário para turma.
#
# Argumentos:
#   - titulo_form (String): Título do formulário.
#   - turma_nome (String): Nome da turma.
#
# Efeitos Colaterais:
#   - Cria Template, Formulario.
Dado('existe um formulário {string} para a turma {string}') do |titulo_form, turma_nome|
  create_form_for_class(titulo_form, turma_nome)
end

# Adiciona pergunta ao formulário atual.
#
# Argumentos:
#   - titulo_form (String): Título form (ignorado na lógica, usa @formulario).
#   - pergunta_texto (String): Pergunta.
#   - tipo (String): Tipo de pergunta.
#
# Efeitos Colaterais:
#   - Cria TemplateQuestion, Questao.
Dado('o formulário {string} tem a pergunta {string} do tipo {string}') do |titulo_form, pergunta_texto, tipo|
  # O código original ignora o titulo_form e usa a variável de instância @formulario
  add_question_to_current_form(pergunta_texto, tipo)
end

# Garante que não há resposta submetida.
#
# Argumentos:
#   - titulo_form (String): Título.
#
# Efeitos Colaterais:
#   - Limpa data_submissao.
Dado('que eu não respondi o formulário {string} ainda') do |titulo_form|
  ensure_unanswered_response(titulo_form)
end

# Visita dashboard.
Dado('eu estou na minha página inicial \(dashboard)') do
  visit root_path
end

# Cria resposta já submetida.
#
# Argumentos:
#   - titulo_form (String): Título.
#
# Efeitos Colaterais:
#   - Cria Resposta com data_submissao.
Dado('que eu já respondi o formulário {string}') do |titulo_form|
  create_submitted_response(titulo_form)
end

# Expira formulário.
#
# Argumentos:
#   - titulo_form (String): Título.
#   - data (String): Data passada.
#
# Efeitos Colaterais:
#   - Update data_encerramento.
Dado('que o formulário {string} expirou em {string}') do |titulo_form, data|
  expire_form_at_date(titulo_form, data)
end

# Remove respostas existentes.
#
# Argumentos:
#   - titulo_form (String): Título.
#
# Efeitos Colaterais:
#   - Deleta Resposta.
Dado('eu não respondi o formulário {string} ainda') do |titulo_form|
  delete_existing_responses(titulo_form)
end

# =========================================
# Ações (Quando)
# =========================================

# Verifica conteúdo em lista.
#
# Argumentos:
#   - texto (String): Conteúdo.
#   - lista_nome (String): Nome lista (ignorado).
Quando('eu vejo {string} na minha lista de {string}') do |texto, lista_nome|
  expect(page).to have_content(texto)
end

# Preenche pergunta no formulário.
#
# Argumentos:
#   - valor (String): Resposta.
#   - pergunta (String): Pergunta.
#
# Efeitos Colaterais:
#   - Interação UI (choose/fill_in).
Quando('eu seleciono {string} para a pergunta {string}') do |valor, pergunta|
  fill_form_question(valor, pergunta)
end

# Tenta acessar página de resposta.
#
# Argumentos:
#   - titulo_form (String): Título.
#
# Efeitos Colaterais:
#   - Visit URL.
Quando('eu tento acessar a página do formulário {string} diretamente') do |titulo_form|
  visit_form_response_page(titulo_form)
end

# Alias para acesso a página.
Quando('eu tento acessar a página do formulário {string}') do |titulo_form|
  visit_form_response_page(titulo_form)
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica redirecionamento para resposta.
#
# Efeitos Colaterais:
#   - Asserção de URL.
Então('eu sou redirecionado para a página do formulário') do
  expect(current_path).to match(/respostas\/new/)
end

# Verifica presença na lista.
#
# Argumentos:
#   - texto (String): Texto.
#   - lista (String): Lista (ignorado).
Então('{string} deve aparecer na minha lista de {string}') do |texto, lista|
  expect(page).to have_content(texto)
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

# Cria matrícula de estudante.
#
# Argumentos:
#   - turma_nome (String): Nome turma.
def create_student_enrollment(turma_nome)
  materia = Materia.find_by(nome: turma_nome) || Materia.create!(nome: turma_nome, codigo: '123')
  
  docente = Usuario.where(ocupacao: :docente).first || Usuario.create!(
    nome: 'Docente', email: 'doc@test.com', usuario: 'doc', 
    password: 'password', ocupacao: :docente, status: true, matricula: 'DOC123'
  )

  @turma = Turma.create!(
    codigo: 'T1', 
    semestre: '2025.1', 
    horario: '10:00', 
    materia: materia,
    docente: docente
  )
  
  Matricula.create!(usuario: @user, turma: @turma)
end

# Cria formulário para turma.
#
# Argumentos:
#   - titulo_form (String): Título.
#   - turma_nome (String): Turma.
def create_form_for_class(titulo_form, turma_nome)
  materia = Materia.find_by(nome: turma_nome)
  turma = Turma.joins(:materia).find_by(materias: { nome: turma_nome })
  
  @template = Template.create!(
    titulo: 'Template Teste', 
    participantes: 'alunos', 
    criador: Usuario.first || @user,
    name: 'Template Name'
  )
  
  @formulario = Formulario.create!(
    titulo_envio: titulo_form,
    data_criacao: Time.now,
    template: @template,
    turma: turma
  )
end

# Adiciona pergunta ao form.
#
# Argumentos:
#   - pergunta_texto (String): Texto.
#   - tipo (String): Tipo.
def add_question_to_current_form(pergunta_texto, tipo)
  q_type = case tipo
           when /numérica/ then 'text'
           when /texto/ then 'text'
           else 'text'
           end
           
  TemplateQuestion.create!(
    title: pergunta_texto,
    question_type: q_type,
    template: @formulario.template,
    content: []
  )
  
  tipo_int = case tipo
             when /numérica/ then 0
             when /texto/ then 0
             else 0
             end

  Questao.create!(
    enunciado: pergunta_texto,
    tipo: tipo_int,
    template: @formulario.template
  )
end

# Garante resposta não respondida.
#
# Argumentos:
#   - titulo_form (String): Título.
def ensure_unanswered_response(titulo_form)
  form = Formulario.find_by(titulo_envio: titulo_form)
  resposta = Resposta.find_or_create_by!(formulario: form, participante: @user)
  resposta.update!(data_submissao: nil) if resposta.data_submissao.present?
end

# Preenche questão no form.
#
# Argumentos:
#   - valor (String): Valor.
#   - pergunta (String): Pergunta.
def fill_form_question(valor, pergunta)
  begin
    choose valor
  rescue Capybara::ElementNotFound
    fill_in pergunta, with: valor
  rescue
    find('label', text: pergunta).find(:xpath, "..//input | ..//textarea").set(valor)
  end
end

# Cria resposta submetida.
#
# Argumentos:
#   - titulo_form (String): Título.
def create_submitted_response(titulo_form)
  form = Formulario.find_by(titulo_envio: titulo_form)
  Resposta.create!(
    formulario: form,
    participante: @user,
    data_submissao: Time.now
  )
end

# Expira formulário.
#
# Argumentos:
#   - titulo_form (String): Título.
#   - data (String): Data fim.
def expire_form_at_date(titulo_form, data)
  form = Formulario.find_by(titulo_envio: titulo_form)
  data_expiracao = Date.strptime(data, "%d/%m/%Y").end_of_day - 1.day
  form.update!(data_encerramento: data_expiracao)
end

# Remove respostas.
#
# Argumentos:
#   - titulo_form (String): Título.
def delete_existing_responses(titulo_form)
   form = Formulario.find_by(titulo_envio: titulo_form)
   Resposta.where(formulario: form, participante: @user).destroy_all
end

# Visita página de resposta.
#
# Argumentos:
#   - titulo_form (String): Título.
def visit_form_response_page(titulo_form)
  form = Formulario.find_by(titulo_envio: titulo_form)
  visit new_formulario_resposta_path(form.id)
end