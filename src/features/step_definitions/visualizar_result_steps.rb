Dado('eu sou um {string} logado no sistema') do |perfil|
  step "que eu sou um '#{perfil}' logado sistema" rescue step "que eu sou um '#{perfil}' logado como '#{perfil}'"
end

Dado('existem os formulários {string} e {string}') do |nome_form1, nome_form2|
  docente = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Prof. Teste",
    email: "prof@teste.com",
    matricula: "12345",
    usuario: "prof123",
    password: "password",
    ocupacao: :docente,
    status: true
  )

  materia = Materia.find_or_create_by!(nome: "Materia Teste", codigo: "MAT01")
  turma = Turma.find_or_create_by!(codigo: "T1", materia: materia) do |t|
    t.semestre = "2025.1"
    t.docente = docente
    t.horario = "10h"
  end

  [nome_form1, nome_form2].each do |titulo|
    template = Template.create!(
      name: titulo,
      titulo: titulo,
      participantes: "todos",
      id_criador: docente.id
    )

    Formulario.create!(
      template: template,
      turma: turma,
      titulo_envio: titulo,
      data_criacao: Time.current,
      data_encerramento: 30.days.from_now
    )
  end
end

Dado(/^(?:que )?existe o formulário "([^"]*)"$/) do |titulo|
  turma = Turma.first || begin
     materia = Materia.create!(nome: 'Materia Teste', codigo: 'MT')
     docente = Usuario.create!(nome: 'Doc', email: 'd@t.com', usuario: 'doc', password: 'p', ocupacao: :docente, status: true, matricula: 'D1')
     Turma.create!(codigo: 'T1', semestre: '2025.1', horario: '10h', materia: materia, docente: docente)
  end
  template = Template.create!(titulo: 'T', participantes: 'alunos', criador: turma.docente, name: 'T')
  @form_target = Formulario.create!(titulo_envio: titulo, data_criacao: Time.now, template: template, turma: turma)
end

Dado('ele possui {int} respostas') do |qtd|
  qtd.times do |i|
    u = Usuario.create!(nome: "User#{i}", email: "u#{i}@t.com", usuario: "u#{i}", password: 'p', ocupacao: :discente, status: true, matricula: "M#{i}")
    Resposta.create!(formulario: @form_target, participante: u, data_submissao: Time.now)
  end
end

Dado(/^(?:que )?não existe nenhum formulário cadastrado$/) do
  Formulario.destroy_all
end



Quando('eu clicoo no botão {string}') do |botao|
   click_on botao
end

Então('eu devo ver {string}') do |texto|
  expect(page).to have_content(texto)
end

Então('eu devo ver a mensaagem {string}') do |msg|
  expect(page).to have_content(msg)
end

Então('eu devo ver um botão {string}') do |botao|
  expect(page).to have_link(botao)
end

Então('eu não devo ver o botão {string}') do |botao|
  expect(page).not_to have_link(botao)
end



Então('o download do arquivo {string} deve iniciar') do |arquivo|
  # Mock check for download headers
  expect(page.response_headers['Content-Disposition']).to include("attachment")
end
