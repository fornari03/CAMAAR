Dado('eu sou um {string} logado no sistema') do |perfil|
  step "que eu sou um '#{perfil}' logado sistema" rescue step "que eu sou um '#{perfil}' logado como '#{perfil}'"
end

Dado('existem os formulários {string} e {string}') do |f1, f2|
  # Create dummy forms
  turma = Turma.first 
  # If factories not setup, manual:
  unless turma
     materia = Materia.create!(nome: 'Materia Teste', codigo: 'MT')
     docente = Usuario.create!(nome: 'Doc', email: 'd@t.com', usuario: 'doc', password: 'p', ocupacao: :docente, status: true, matricula: 'D1')
     turma = Turma.create!(codigo: 'T1', semestre: '2025.1', horario: '10h', materia: materia, docente: docente)
  end
  template = Template.create!(titulo: 'T', participantes: 'alunos', criador: turma.docente, name: 'T')
  
  [f1, f2].each do |f|
    Formulario.create!(titulo_envio: f, data_criacao: Time.now, template: template, turma: turma)
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
