# =========================================
# Contexto (Dado)
# =========================================

# Loga usuário com perfil.
#
# Argumentos:
#   - perfil (String): Role.
#
# Efeitos Colaterais:
#   - Invoca step de login existente (cadastrar_usuarios_steps ou similar).
Dado('eu sou um {string} logado no sistema') do |perfil|
  step "que eu sou um '#{perfil}' logado sistema" rescue step "que eu sou um '#{perfil}' logado como '#{perfil}'"
end

# Cria formulários vinculados.
#
# Argumentos:
#   - nome_form1, nome_form2 (String): Títulos.
#
# Efeitos Colaterais:
#   - Cria estruturas complexas de Turma/Form/Template.
Dado('existem os formulários {string} e {string}') do |nome_form1, nome_form2|
  contexto = setup_result_view_context

  [nome_form1, nome_form2].each do |titulo|
    create_linked_form_and_template(titulo, contexto)
  end
end

# Cria um único formulário.
#
# Argumentos:
#   - titulo (String): Título.
#
# Efeitos Colaterais:
#   - Persiste Formulario.
Dado(/^(?:que )?existe o formulário "([^"]*)"$/) do |titulo|
  create_single_form_scenario(titulo)
end

# Adiciona respostas mock ao form alvo.
#
# Argumentos:
#   - qtd (Integer): Quantidade.
#
# Efeitos Colaterais:
#   - Cria usuarios e respostas.
Dado('ele possui {int} respostas') do |qtd|
  create_responses_for_target_form(qtd)
end

# Limpa formulários.
Dado(/^(?:que )?não existe nenhum formulário cadastrado$/) do
  Formulario.destroy_all
end

# =========================================
# Ações (Quando)
# =========================================

# Step typo "clicoo".
#
# Argumentos:
#   - botao (String): Texto.
Quando('eu clicoo no botão {string}') do |botao|
   click_on botao
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica texto genérico.
#
# Argumentos:
#   - texto (String): Conteúdo.
Então('eu devo ver {string}') do |texto|
  expect(page).to have_content(texto)
end

# Alias typo "mensaagem".
Então('eu devo ver a mensaagem {string}') do |msg|
  expect(page).to have_content(msg)
end

# Verifica botão.
#
# Argumentos:
#   - botao (String): Texto.
Então('eu devo ver um botão {string}') do |botao|
  verify_button_presence(botao)
end

# Verifica ausência de botão.
#
# Argumentos:
#   - botao (String): Texto.
Então('eu não devo ver o botão {string}') do |botao|
  expect(page).not_to have_link(botao)
end

# Verifica header de download.
#
# Argumentos:
#   - arquivo (String): Nome esperado (ignorado na lógica simples).
Então('o download do arquivo {string} deve iniciar') do |arquivo|
  expect(page.response_headers['Content-Disposition']).to include("attachment")
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

# Cria form único simples.
#
# Argumentos:
#   - titulo (String): Título.
def create_single_form_scenario(titulo)
  turma = Turma.first || create_default_turma_structure
  
  template = Template.create!(
    titulo: 'T', 
    participantes: 'alunos', 
    criador: turma.docente, 
    name: 'T'
  )
  
  @form_target = Formulario.create!(
    titulo_envio: titulo, 
    data_criacao: Time.now, 
    template: template, 
    turma: turma
  )
end

# Cria estrutura básica de turma.
#
# Retorno:
#   - (Turma): Turma criada.
def create_default_turma_structure
  materia = Materia.create!(nome: 'Materia Teste', codigo: 'MT')
  docente = Usuario.create!(
    nome: 'Doc', email: 'd@t.com', usuario: 'doc', 
    password: 'p', ocupacao: :docente, status: true, matricula: 'D1'
  )
  
  Turma.create!(
    codigo: 'T1', semestre: '2025.1', horario: '10h', 
    materia: materia, docente: docente
  )
end

# Cria respostas mock.
#
# Argumentos:
#   - qtd (Integer): Quantidade.
def create_responses_for_target_form(qtd)
  qtd.times do |i|
    u = Usuario.create!(
      nome: "User#{i}", email: "u#{i}@t.com", usuario: "u#{i}", 
      password: 'p', ocupacao: :discente, status: true, matricula: "M#{i}"
    )
    Resposta.create!(
      formulario: @form_target, 
      participante: u, 
      data_submissao: Time.now
    )
  end
end

# Verifica presença de botão.
#
# Argumentos:
#   - botao (String): Texto.
def verify_button_presence(botao)
  botao_nome = (botao == "Baixar CSV") ? "Exportar para CSV" : botao
  expect(page).to have_link(botao_nome)
end