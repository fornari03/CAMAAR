# =========================================
# Contexto (Dado)
# =========================================

Dado('que eu sou um {string} logado como {string}') do |role, username|
  ocupacao = resolve_responder_occupation(role)
  @user = find_or_create_responder_user(username, ocupacao)
  perform_ui_login(@user.email, 'password')
end

Dado('eu estou matriculado na turma {string}') do |turma_nome|
  create_student_enrollment(turma_nome)
end

Dado('existe um formulário {string} para a turma {string}') do |titulo_form, turma_nome|
  create_form_for_class(titulo_form, turma_nome)
end

Dado('o formulário {string} tem a pergunta {string} do tipo {string}') do |titulo_form, pergunta_texto, tipo|
  # O código original ignora o titulo_form e usa a variável de instância @formulario
  add_question_to_current_form(pergunta_texto, tipo)
end

Dado('que eu não respondi o formulário {string} ainda') do |titulo_form|
  ensure_unanswered_response(titulo_form)
end

Dado('eu estou na minha página inicial \(dashboard)') do
  visit root_path
end

Dado('que eu já respondi o formulário {string}') do |titulo_form|
  create_submitted_response(titulo_form)
end

Dado('que o formulário {string} expirou em {string}') do |titulo_form, data|
  expire_form_at_date(titulo_form, data)
end

Dado('eu não respondi o formulário {string} ainda') do |titulo_form|
  delete_existing_responses(titulo_form)
end

# =========================================
# Ações (Quando)
# =========================================

Quando('eu vejo {string} na minha lista de {string}') do |texto, lista_nome|
  expect(page).to have_content(texto)
end

Quando('eu seleciono {string} para a pergunta {string}') do |valor, pergunta|
  fill_form_question(valor, pergunta)
end

Quando('eu tento acessar a página do formulário {string} diretamente') do |titulo_form|
  visit_form_response_page(titulo_form)
end

Quando('eu tento acessar a página do formulário {string}') do |titulo_form|
  visit_form_response_page(titulo_form)
end

# =========================================
# Verificações (Então)
# =========================================

Então('eu sou redirecionado para a página do formulário') do
  expect(current_path).to match(/respostas\/new/)
end

Então('{string} deve aparecer na minha lista de {string}') do |texto, lista|
  expect(page).to have_content(texto)
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

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

def ensure_unanswered_response(titulo_form)
  form = Formulario.find_by(titulo_envio: titulo_form)
  resposta = Resposta.find_or_create_by!(formulario: form, participante: @user)
  resposta.update!(data_submissao: nil) if resposta.data_submissao.present?
end

def fill_form_question(valor, pergunta)
  begin
    choose valor
  rescue Capybara::ElementNotFound
    fill_in pergunta, with: valor
  rescue
    find('label', text: pergunta).find(:xpath, "..//input | ..//textarea").set(valor)
  end
end

def create_submitted_response(titulo_form)
  form = Formulario.find_by(titulo_envio: titulo_form)
  Resposta.create!(
    formulario: form,
    participante: @user,
    data_submissao: Time.now
  )
end

def expire_form_at_date(titulo_form, data)
  form = Formulario.find_by(titulo_envio: titulo_form)
  data_expiracao = Date.strptime(data, "%d/%m/%Y").end_of_day - 1.day
  form.update!(data_encerramento: data_expiracao)
end

def delete_existing_responses(titulo_form)
   form = Formulario.find_by(titulo_envio: titulo_form)
   Resposta.where(formulario: form, participante: @user).destroy_all
end

def visit_form_response_page(titulo_form)
  form = Formulario.find_by(titulo_envio: titulo_form)
  visit new_formulario_resposta_path(form.id)
end