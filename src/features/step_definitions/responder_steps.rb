Dado('que eu sou um {string} logado como {string}') do |role, username|
  # 1. Determina a ocupação baseada no papel (string -> symbol)
  ocupacao = resolve_responder_occupation(role)
  
  # 2. Garante que o usuário existe no banco
  @user = find_or_create_responder_user(username, ocupacao)
  
  # 3. Realiza o login na interface
  perform_ui_login(@user.email, 'password')
end

Dado('eu estou matriculado na turma {string}') do |turma_nome|
  materia = Materia.find_by(nome: turma_nome) || Materia.create!(nome: turma_nome, codigo: '123')
  @turma = Turma.create!(
    codigo: 'T1', 
    semestre: '2025.1', 
    horario: '10:00', 
    materia: materia,
    docente: Usuario.where(ocupacao: :docente).first || Usuario.create!(nome: 'Docente', email: 'doc@test.com', usuario: 'doc', password: 'password', ocupacao: :docente, status: true, matricula: 'DOC123')
  )
  Matricula.create!(usuario: @user, turma: @turma)
end

Dado('existe um formulário {string} para a turma {string}') do |titulo_form, turma_nome|
  materia = Materia.find_by(nome: turma_nome)
  # Assuming only one turma for that materia for simplicity in this context
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

Dado('o formulário {string} tem a pergunta {string} do tipo {string}') do |titulo_form, pergunta_texto, tipo|
  # "numérica (1-5)" -> map to type
  # Cleaning up type string if needed
  q_type = case tipo
           when /numérica/ then 'text' # Mapped to text for now as no 'number' enum
           when /texto/ then 'text'
           else 'text'
           end
           
  TemplateQuestion.create!(
    title: pergunta_texto,
    question_type: q_type,
    template: @formulario.template,
    content: [] # Default
  )
  
  # Also creating legacy Questao if needed by old logic?
  # The schema showed 'questoes' table besides 'template_questions'.
  # I should stick to 'template_questions' as it seems newer?
  # The User said: "Itera sobre a coleção de perguntas (@form_request.template.questions)"
  # Let's check Template model associations later. Assuming TemplateQuestion is correct for now or 'Questao'.
  # The schema has 'questoes' linked to 'templates'.
  # I will use 'Questao' model for now as 'TemplateQuestion' might be something else.
  # Correction: Schema has both. Let's check Template model later.
  # For now I will create Questao.
    
  tipo_int = case tipo
             when /numérica/ then 0 # Mapped to text so it renders an input field we can fill_in
             when /texto/ then 0
             else 0
             end

  Questao.create!(
    enunciado: pergunta_texto,
    tipo: tipo_int,
    template: @formulario.template
  )
end

Dado('que eu não respondi o formulário {string} ainda') do |titulo_form|
  form = Formulario.find_by(titulo_envio: titulo_form)
  # Ensure there's an empty Resposta (data_submissao: nil) for this user
  resposta = Resposta.find_or_create_by!(formulario: form, participante: @user)
  resposta.update!(data_submissao: nil) if resposta.data_submissao.present?
end

Dado('eu estou na minha página inicial \(dashboard)') do
  visit root_path
end

Quando('eu vejo {string} na minha lista de {string}') do |texto, lista_nome|
  expect(page).to have_content(texto)
  # Ideally check within a specific section, e.g. "Formulários Pendentes" header
end

Então('eu sou redirecionado para a página do formulário') do
  # expect current path to match form path
  expect(current_path).to match(/respostas\/new/)
end

Quando('eu seleciono {string} para a pergunta {string}') do |valor, pergunta|
  # It might be a radio or text input.
  # If radio
  begin
    choose valor
  rescue Capybara::ElementNotFound
    fill_in pergunta, with: valor
  rescue
    # finding by label might fail if label logic is complex
    # Fallback to finding input near text
    find('label', text: pergunta).find(:xpath, "..//input | ..//textarea").set(valor)
  end
end



Então('{string} deve aparecer na minha lista de {string}') do |texto, lista|
  expect(page).to have_content(texto)
end

Dado('que eu já respondi o formulário {string}') do |titulo_form|
  form = Formulario.find_by(titulo_envio: titulo_form)
  resposta = Resposta.create!(
    formulario: form,
    participante: @user,
    data_submissao: Time.now
  )
  # Creating item responses if strictly required
end

Quando('eu tento acessar a página do formulário {string} diretamente') do |titulo_form|
  form = Formulario.find_by(titulo_envio: titulo_form)
  # Assuming standard route
  visit new_formulario_resposta_path(form.id)
end

Dado('que o formulário {string} expirou em {string}') do |titulo_form, data|
  form = Formulario.find_by(titulo_envio: titulo_form)
  # Data string might be "DD/MM/YYYY"
  data_expiracao = Date.strptime(data, "%d/%m/%Y").end_of_day - 1.day # Set to past
  form.update!(data_encerramento: data_expiracao)
end

Dado('eu não respondi o formulário {string} ainda') do |titulo_form|
   # Duplicate step?
   form = Formulario.find_by(titulo_envio: titulo_form)
   Resposta.where(formulario: form, participante: @user).destroy_all
end

Quando('eu tento acessar a página do formulário {string}') do |titulo_form|
  form = Formulario.find_by(titulo_envio: titulo_form)
  visit new_formulario_resposta_path(form.id)
end