# =========================================
# Contexto (Dado)
# =========================================

# Cria turmas mockadas do SIGAA com estrutura completa.
#
# Argumentos:
#   - nome_turma1 (String): Nome da primeira turma.
#   - nome_turma2 (String): Nome da segunda turma.
#
# Efeitos Colaterais:
#   - Persiste User, Materia, Turma.
Dado('existem as turmas {string} e {string} importadas do SIGAA') do |nome_turma1, nome_turma2|
  docente = find_or_create_default_teacher

  [nome_turma1, nome_turma2].each do |nome_completo|
    create_sigaa_class_structure(nome_completo, docente)
  end
end

# Cria template básico.
#
# Argumentos:
#   - nome_template (String): Nome do template.
#
# Efeitos Colaterais:
#   - Persiste Template e Usuario criador.
Dado('existe um template {string}') do |nome_template|
  find_or_create_template(nome_template)
end

# =========================================
# Ações (Quando)
# =========================================

# Seleciona template no combobox.
#
# Argumentos:
#   - nome_template (String): Nome.
Quando('eu seleciono o template {string}') do |nome_template|
  select nome_template, from: "Template"
end

# Seleciona duas turmas (checkbox).
#
# Argumentos:
#   - turma1 (String): Nome turma 1.
#   - turma2 (String): Nome turma 2.
Quando('eu seleciono as turmas {string} e {string}') do |turma1, turma2|
  check turma1
  check turma2
end

# Seleciona uma turma (checkbox).
#
# Argumentos:
#   - turma1 (String): Nome.
Quando('eu seleciono as turmas {string}') do |turma1|
  check turma1
end

# Preenche data de encerramento.
#
# Argumentos:
#   - data (String): Data em string.
Quando('eu defino a data de encerramento para {string}') do |data|
  fill_in "Data de encerramento", with: data
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica redirecionamento por nome de rota.
#
# Argumentos:
#   - page_name (String): Nome da rota/página.
Então('eu devo ser redirecionado para a página {string}') do |page_name|
  expect(page).to have_current_path(path_to(page_name))
end

# Verifica associação do último formulário criado.
#
# Argumentos:
#   - nome_template (String): Nome do template esperado.
#
# Retorno:
#   - (Boolean): Asserção de igualdade.
Então('o formulário deve estar associado ao template {string}') do |nome_template|
  verify_last_form_template(nome_template)
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

# Encontra ou cria template.
#
# Argumentos:
#   - nome_template (String): Nome.
#
# Retorno:
#   - (Template): Objeto template.
def find_or_create_template(nome_template)
  criador = Usuario.first || Usuario.create!(
    nome: "Admin", email: "admin@test.com", matricula: "0000", 
    usuario: "admin", password: "password", ocupacao: :admin, status: true
  )
  
  Template.find_or_create_by!(name: nome_template) do |t|
    t.titulo = nome_template
    t.participantes = "todos"
    t.id_criador = criador.id
  end
end

# Verifica template do último formulário.
#
# Argumentos:
#   - nome_template (String): Nome esperado.
def verify_last_form_template(nome_template)
  formulario = Formulario.last
  expect(formulario.template.name).to eq(nome_template)
end