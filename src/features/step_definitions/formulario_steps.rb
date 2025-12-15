Dado('existem as turmas {string} e {string} importadas do SIGAA') do |nome_turma1, nome_turma2|
  # 1. Garante que existe um docente para associar
  docente = find_or_create_default_teacher

  # 2. Itera sobre os nomes e cria a estrutura para cada um
  [nome_turma1, nome_turma2].each do |nome_completo|
    create_sigaa_class_structure(nome_completo, docente)
  end
end

Dado('existe um template {string}') do |nome_template|
  criador = Usuario.first || Usuario.create!(
    nome: "Admin", email: "admin@test.com", matricula: "0000", usuario: "admin", password: "password", ocupacao: :admin, status: true
  )
  
  Template.find_or_create_by!(name: nome_template) do |t|
    t.titulo = nome_template
    t.participantes = "todos"
    t.id_criador = criador.id
  end
end

Quando('eu seleciono o template {string}') do |nome_template|
  select nome_template, from: "Template"
end

Quando('eu seleciono as turmas {string} e {string}') do |turma1, turma2|
  check turma1
  check turma2
end

Quando('eu seleciono as turmas {string}') do |turma1|
  check turma1
end

Quando('eu defino a data de encerramento para {string}') do |data|
  fill_in "Data de encerramento", with: data
end

Então('eu devo ser redirecionado para a página {string}') do |page_name|
  expect(page).to have_current_path(path_to(page_name))
end

Então('o formulário deve estar associado ao template {string}') do |nome_template|
  formulario = Formulario.last
  expect(formulario.template.name).to eq(nome_template)
end