Dado('existem as turmas {string} e {string} importadas do SIGAA') do |nome_turma1, nome_turma2|
  docente = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Docente Padrão",
    email: "docente@camaar.unb.br",
    matricula: "DOC123",
    usuario: "docente",
    password: "password",
    ocupacao: :docente,
    status: true
  )

  [nome_turma1, nome_turma2].each do |nome_completo|
    if nome_completo.include?(' - ')
      nome_materia, codigo_turma = nome_completo.split(' - ')
    else
      nome_materia = nome_completo
      codigo_turma = "A"
    end

    materia = Materia.find_or_create_by!(nome: nome_materia) do |m|
      m.codigo = nome_materia[0..3].upcase
    end

    Turma.find_or_create_by!(codigo: codigo_turma, materia: materia) do |t|
      t.semestre = "2025.1"
      t.horario = "24M34"
      t.docente = docente
    end
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